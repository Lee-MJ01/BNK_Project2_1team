package kr.co.api.backend.config;

import com.zaxxer.hikari.HikariDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.LazyConnectionDataSourceProxy;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

@Configuration
@MapperScan(
        basePackages = "kr.co.api.backend.mapper",
        sqlSessionFactoryRef = "sqlSessionFactory"
)
public class MyBatisConfig {

    @Autowired
    private DbStatusManager dbStatusManager;

    // 접속 정보는 코드에 두지 않고 환경변수(application.yml)에서 주입한다
    @Value("${spring.datasource.master.jdbc-url}")
    private String masterUrl;
    @Value("${spring.datasource.master.username}")
    private String masterUsername;
    @Value("${spring.datasource.master.password}")
    private String masterPassword;

    @Value("${spring.datasource.slave.jdbc-url}")
    private String slaveUrl;
    @Value("${spring.datasource.slave.username}")
    private String slaveUsername;
    @Value("${spring.datasource.slave.password}")
    private String slavePassword;

    // 감시자용 성격 급한 DataSource (Timeout 1초)
    @Bean(name = "masterPingDataSource")
    public DataSource masterPingDataSource() {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(masterUrl);
        dataSource.setUsername(masterUsername);
        dataSource.setPassword(masterPassword);
        dataSource.setDriverClassName("oracle.jdbc.OracleDriver");

        dataSource.setConnectionTimeout(1000); // 1초
        dataSource.setValidationTimeout(1000);
        dataSource.setPoolName("Master-Ping-Pool");
        dataSource.setMaximumPoolSize(1);
        return dataSource;
    }

    // [2] Slave 감시용
    @Bean(name = "slavePingDataSource")
    public DataSource slavePingDataSource() {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(slaveUrl);
        dataSource.setUsername(slaveUsername);
        dataSource.setPassword(slavePassword);
        dataSource.setDriverClassName("oracle.jdbc.OracleDriver");

        // ★ 핵심: 1초 안에 연결 안 되면 바로 포기!
        dataSource.setConnectionTimeout(1000);
        dataSource.setValidationTimeout(1000);
        dataSource.setPoolName("Slave-Ping-Pool");
        dataSource.setMaximumPoolSize(1);
        return dataSource;
    }

    // 1. Master DB
    @Bean(name = "masterDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.master")
    public DataSource masterDataSource() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    // 2. Slave DB (이름 변경됨: realSlaveDataSource)
    @Bean(name = "realSlaveDataSource")
    public DataSource realSlaveDataSource() {
        HikariDataSource dataSource = new HikariDataSource();

        dataSource.setJdbcUrl(slaveUrl);
        dataSource.setUsername(slaveUsername);
        dataSource.setPassword(slavePassword);
        dataSource.setDriverClassName("oracle.jdbc.OracleDriver");

        dataSource.setPoolName("Slave-HikariCP");

        dataSource.setMaximumPoolSize(10);
        dataSource.setMinimumIdle(5);
        dataSource.setConnectionTimeout(30000);

        System.out.println(">>> [MyBatisConfig] realSlaveDataSource 생성 완료");
        return dataSource;
    }

    // 3. Routing (Master + Slave)
    @Bean(name = "routingDataSource")
    public DataSource routingDataSource(
            @Qualifier("masterDataSource") DataSource masterDataSource,
            @Qualifier("realSlaveDataSource") DataSource realSlaveDataSource) {

        ReplicationRoutingDataSource routingDataSource = new ReplicationRoutingDataSource(dbStatusManager);
        Map<Object, Object> dataSourceMap = new HashMap<>();

        // 매핑
        dataSourceMap.put("master", masterDataSource);
        dataSourceMap.put("slave", realSlaveDataSource);

        routingDataSource.setTargetDataSources(dataSourceMap);
        routingDataSource.setDefaultTargetDataSource(masterDataSource);
        return routingDataSource;
    }

    // 4. Proxy (Transaction)
    @Bean(name = "dataSource")
    @Primary
    public DataSource dataSource(@Qualifier("routingDataSource") DataSource routingDataSource) {
        return new LazyConnectionDataSourceProxy(routingDataSource);
    }

    // 5. Main SqlSessionFactory (라우팅용)
    @Bean(name = "sqlSessionFactory")
    @Primary
    public SqlSessionFactory sqlSessionFactory(@Qualifier("dataSource") DataSource dataSource) throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource);
        sessionFactory.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath:mappers/**/*.xml"));
        sessionFactory.setTypeAliasesPackage("kr.co.api.backend.model, kr.co.api.backend.dto.search, kr.co.api.backend.dto");
        org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(true);
        sessionFactory.setConfiguration(configuration);
        return sessionFactory.getObject();
    }

    @Bean(name = "sqlSessionTemplate")
    @Primary
    public SqlSessionTemplate sqlSessionTemplate(@Qualifier("sqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

    // =============================================================
    // ★ [핵심] Slave 전용 직통 라인 (라우팅 안 거침!)
    // =============================================================
    @Bean(name = "slaveSqlSessionFactory")
    public SqlSessionFactory slaveSqlSessionFactory(
            @Qualifier("realSlaveDataSource") DataSource realSlaveDataSource) throws Exception { // ★ 여기가 틀렸었음!

        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        // ★ 라우팅이 아닌 'realSlaveDataSource'를 직접 꽂습니다.
        sessionFactory.setDataSource(realSlaveDataSource);

        sessionFactory.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath:mappers/**/*.xml"));
        sessionFactory.setTypeAliasesPackage("kr.co.api.backend.model, kr.co.api.backend.dto.search, kr.co.api.backend.dto");
        org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(true);
        sessionFactory.setConfiguration(configuration);
        return sessionFactory.getObject();
    }

    @Bean(name = "slaveSqlSessionTemplate")
    public SqlSessionTemplate slaveSqlSessionTemplate(@Qualifier("slaveSqlSessionFactory") SqlSessionFactory slaveSqlSessionFactory) {
        return new SqlSessionTemplate(slaveSqlSessionFactory);
    }

    // 6. 트랜잭션 매니저
    @Bean(name = "transactionManager")
    @Primary
    public PlatformTransactionManager transactionManager(@Qualifier("dataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    @Bean(name = "slaveTransactionManager")
    public PlatformTransactionManager slaveTransactionManager(
            @Qualifier("realSlaveDataSource") DataSource realSlaveDataSource) { // ★ 여기도 중요!
        return new DataSourceTransactionManager(realSlaveDataSource);
    }
}