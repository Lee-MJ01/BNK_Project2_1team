allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// [핵심 해결책]
// 'app' 모듈은 제외하고, 나머지 '플러그인'들만 강제로 SDK 34로 설정합니다.
// 이렇게 하면 afterEvaluate 에러도 피하고, lStar 에러도 해결됩니다.
subprojects {
    if (project.name != "app") {
        project.afterEvaluate {
            if (project.plugins.hasPlugin("com.android.library")) {
                project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                    compileSdk = 36
                    defaultConfig {
                        targetSdk = 36
                    }
                }
            }
        }
    }
}

// 라이브러리 버전 충돌 방지용 (그대로 유지)
subprojects {
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.core:core:1.13.1")
            force("androidx.activity:activity:1.9.3")
            force("androidx.appcompat:appcompat:1.7.0")
        }
    }
}