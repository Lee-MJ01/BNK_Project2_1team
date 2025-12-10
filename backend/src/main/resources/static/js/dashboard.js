// dashboard.js

document.addEventListener('DOMContentLoaded', function () {
    if (!window.dashboardData) {
        console.warn('dashboardData가 없습니다.');
        return;
    }

    const dataObj = window.dashboardData;

    // 1) 원화 요약 카드 숫자 세팅

    const totalTxCount = dataObj.todayTotalTxCount || 0;      // 오늘 총 거래 건수
    const totalTxAmount = dataObj.todayTotalTxAmount || 0;    // 오늘 총 거래 금액 (원)

    // 카드 1: 총 거래 건수
    const totalTxCountTextEl = document.getElementById('totalTxCountText');
    if (totalTxCountTextEl) {
        totalTxCountTextEl.textContent = totalTxCount.toLocaleString('ko-KR') + '건';
    }

    // 카드 2: 총 거래 금액
    const totalTxAmountTextEl = document.getElementById('totalTxAmountText');
    if (totalTxAmountTextEl) {
        let displayText;
        const oneHundredMillion = 100000000;

        if (totalTxAmount >= oneHundredMillion) {
            const amountInEok = totalTxAmount / oneHundredMillion;
            displayText = amountInEok.toFixed(1) + '억';
        } else {
            displayText = totalTxAmount.toLocaleString('ko-KR') + '원';
        }
        totalTxAmountTextEl.textContent = displayText;
    }


    // 1-1) 전일 대비 % 계산

    const last7 = dataObj.last7Days || [];
    let countDiffPercent = null;
    let amountDiffPercent = null;

    if (Array.isArray(last7) && last7.length >= 2) {
        const todayDaily = last7[last7.length - 1];   // 오늘
        const yesterDaily = last7[last7.length - 2];  // 어제

        const todayCountDaily = todayDaily && todayDaily.count != null ? todayDaily.count : null;
        const yesterdayCountDaily = yesterDaily && yesterDaily.count != null ? yesterDaily.count : null;

        if (yesterdayCountDaily && yesterdayCountDaily > 0 && todayCountDaily != null) {
            countDiffPercent = ((todayCountDaily - yesterdayCountDaily) * 100) / yesterdayCountDaily;
        }

        const todayAmountDaily = todayDaily && todayDaily.amount != null ? todayDaily.amount : null;
        const yesterdayAmountDaily = yesterDaily && yesterDaily.amount != null ? yesterDaily.amount : null;

        if (yesterdayAmountDaily && yesterdayAmountDaily > 0 && todayAmountDaily != null) {
            amountDiffPercent = ((todayAmountDaily - yesterdayAmountDaily) * 100) / yesterdayAmountDaily;
        }
    }

    const countDiffEl = document.getElementById('totalTxCountDiff');
    if (countDiffEl) {
        if (countDiffPercent != null) {
            const rounded = Math.round(countDiffPercent * 10) / 10; // 소수 1자리
            const sign = rounded > 0 ? '+' : '';
            countDiffEl.textContent = `${sign}${rounded}%`;
            countDiffEl.classList.toggle('diff-up', rounded >= 0);
            countDiffEl.classList.toggle('diff-down', rounded < 0);
        } else {
            countDiffEl.textContent = '-';
            countDiffEl.classList.remove('diff-up', 'diff-down');
        }
    }

    const amountDiffEl = document.getElementById('totalTxAmountDiff');
    if (amountDiffEl) {
        if (amountDiffPercent != null) {
            const rounded = Math.round(amountDiffPercent * 10) / 10;
            const sign = rounded > 0 ? '+' : '';
            amountDiffEl.textContent = `${sign}${rounded}%`;
            amountDiffEl.classList.toggle('diff-up', rounded >= 0);
            amountDiffEl.classList.toggle('diff-down', rounded < 0);
        } else {
            amountDiffEl.textContent = '-';
            amountDiffEl.classList.remove('diff-up', 'diff-down');
        }
    }


    // 2) 원화 미니차트 (건수/금액 스파크라인)
    if (typeof Chart === 'undefined') {
        console.warn('Chart.js가 로드되지 않았습니다.');
        return;
    }

    let countTrendData = [];
    let amountTrendData = [];
    let trendLabels = ['6일 전', '5일 전', '4일 전', '3일 전', '2일 전', '1일 전', '오늘'];

    if (Array.isArray(last7) && last7.length > 0) {
        trendLabels = last7.map(d => d.date || '');
        countTrendData = last7.map(d => d.count != null ? d.count : 0);
        amountTrendData = last7.map(d => d.amount != null ? d.amount : 0);
    } else {
        trendLabels = ['오늘'];
        countTrendData = [totalTxCount];
        amountTrendData = [totalTxAmount];
    }
    trendLabels = trendLabels.map(v => String(v ?? '').replace(/^"+|"+$/g, '').replace(/"/g, ''));

    // (1) 건수 미니차트
    const krwCountCanvas = document.getElementById('krwCountMiniChart');
    if (krwCountCanvas) {
        const ctx = krwCountCanvas.getContext('2d');

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: trendLabels,
                datasets: [
                    {
                        data: countTrendData,
                        borderColor: '#2196f3',
                        backgroundColor: 'rgba(244,244,244,0)',
                        tension: 0,
                        fill: true,
                        pointRadius: 0,
                        hoverRadius: 0,
                        pointHitRadius: 15

                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        enabled: true,
                        callbacks: {
                            label: function (ctx) {
                                const value = ctx.parsed.y || 0;
                                return value.toLocaleString('ko-KR') + ' 건';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true
                    },
                    y: {

                        display: true,
                        beginAtZero: true,
                        grace: '10%'
                    }
                }
            }
        });
    }

    // (2) 금액 미니차트
    const krwAmountCanvas = document.getElementById('krwAmountMiniChart');
    if (krwAmountCanvas) {
        const ctx = krwAmountCanvas.getContext('2d');
        const maxAmount = Math.max(...amountTrendData.map(v => Number(v) || 0));
        const amountUnit =
            maxAmount >= 100000000 ? '억' :
                maxAmount >= 10000000  ? '천만' :
                    maxAmount >= 10000     ? '만' : '';

        // ✅ 단위 포맷 함수
        const formatAmount = (value) => {
            const n = Number(value) || 0;
            const abs = Math.abs(n);

            if (amountUnit === '억') {
                const x = n / 100000000;
                return (Number.isInteger(x) ? x : x.toFixed(1)) + '억';
            }
            if (amountUnit === '천만') {
                const x = n / 10000000;
                return (Number.isInteger(x) ? x : x.toFixed(1)) + '천만';
            }
            if (amountUnit === '만') {
                const x = n / 10000;
                return (Number.isInteger(x) ? x : x.toFixed(1)) + '만';
            }

            // 1만 미만이면 그냥 콤마
            return n.toLocaleString('ko-KR');
        };

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: trendLabels,
                datasets: [
                    {
                        data: amountTrendData,
                        borderColor: '#2196f3',
                        backgroundColor: 'rgba(244,244,244, 0)',
                        tension: 0,
                        fill: true,
                        pointRadius: 1,
                        hoverRadius: 0,
                        pointHitRadius: 15
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: true,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        enabled: true,
                        callbacks: {
                            label: function (ctx) {
                                const value = ctx.parsed.y || 0;
                                return value.toLocaleString('ko-KR') + ' 원';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true
                    },
                    y: {
                        display: true,
                        beginAtZero: true,
                        grace: '10%',
                        ticks: {
                            maxTicksLimit: 7,
                            callback: function (value) {
                                return formatAmount(value);
                            }
                        }
                    }
                }
            }
        });
    }

    // -----------------------------
    // 3) 외화 거래 수 차트 (환전 / 외화송금)
    // -----------------------------
    const fxList = dataObj.todayFxTxCounts || [];
    const fxCanvas = document.getElementById('fxChart');

    if (fxCanvas && fxList.length > 0) {
        const labels = fxList.map(tx => tx.type);           // "환전", "외화송금"
        const counts = fxList.map(tx => tx.count || 0);
        const maxValue = counts.length > 0 ? Math.max(...counts) : 0;

        const fxCtx = fxCanvas.getContext('2d');
        new Chart(fxCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '오늘 외화 거래 건수',
                        data: counts,
                        borderColor: '#f8d4d4',
                        backgroundColor: 'rgb(229,210,229)',
                        barPercentage: 0.6,
                        categoryPercentage: 0.5,
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: true,
                plugins: {
                    legend: {
                        display: false,
                        position: 'top'
                    },
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        suggestedMax: maxValue + 1,
                        ticks: {
                            precision: 0,
                            grid: {
                                drawBorder: true
                            },
                            border: {
                                display: true
                            }
                        },
                        yR: {
                            position: 'right',
                            grid: {
                                drawOnChartArea: false,  // 오른쪽 축이 그리드를 또 그리면 지저분해짐
                                drawBorder: true
                            },
                            border: {
                                display: true
                            },
                            ticks: {
                                display: false
                            }
                        }
                    }
                },
                onClick: (event, activeElements) => {
                    if (!activeElements || activeElements.length === 0) return;

                    const chart = activeElements[0].element.$context.chart;
                    const index = activeElements[0].index;
                    const label = chart.data.labels[index];

                    // 라벨별 이동 URL 매핑
                    let url = null;
                    if (label === '환전') {
                        url = '/flobank/admin/exchange';
                    }
                    if (url) {
                        window.location.href = url;
                    }
                }
            }
        });
    } else if (!fxList.length) {
        console.warn('todayFxTxCounts 데이터가 비어 있습니다.');
    }

    //----------------------------------------------------------------
    //----------------------------------------------------------------
    //----------------------------------------------------------------


    (function () {
        const dataObj = window.dashboardData || {};

        // 일별
        const dailyJoinChartEl = document.getElementById('joinDailyChart');
        if (dailyJoinChartEl) {
            const array = Array.isArray(dataObj.dailyJoinStats) ? dataObj.dailyJoinStats : [];

            const labels = array.map(item => {
                if (!item || !item.baseDate) return '';
                const raw = String(item.baseDate).replace(/"/g, '');
                if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
                    return raw.slice(5).replace('-','/');   // '11-24'
                    // 만약 '11/24' 로 보이고 싶으면: return raw.slice(5).replace('-', '/');
                }

                // 3) YYYY-MM 형식이면 'MM'만
                if (/^\d{4}-\d{2}$/.test(raw)) {
                    return raw.slice(5);   // '11'
                }
                return raw;
            });
            const data = array.map(item =>
                item && typeof item.joinCount === 'number' ? item.joinCount : 0
            );

            const maxVal = data.length > 0 ? Math.max(...data) : 0;

            window.joindailyChartInstance = new Chart(dailyJoinChartEl.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '일별 가입자 수',
                        data: data,
                        borderColor: '#cf8bb0',
                        backgroundColor: 'rgba(253,188,223,0.2)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3
                    }]
                },
                options: {
                    scales: {
                        x:{
                            grid:{
                                display: false
                            }
                        },
                        y: {
                            display: true,
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1,
                                precision: 0 // 정수로만
                            },
                            suggestedMax: maxVal === 0 ? 1 : maxVal + 1
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
        const weeklyJoinChartEl = document.getElementById('joinWeeklyChart');
        if (weeklyJoinChartEl) {
            const weeklyArray = Array.isArray(dataObj.weeklyJoinStats) ? dataObj.weeklyJoinStats : [];

            const labels = weeklyArray.map(item => {
                if (!item || !item.baseDate) return '';

                // baseDate가 "\"2025-10-20\"" 이런 식으로 들어와도 정리
                const raw = String(item.baseDate).replace(/^"|"$/g, '');

                const weekStart = new Date(raw);
                if (Number.isNaN(weekStart.getTime())) {
                    // 혹시 Date로 못 바꾸면 원래 문자열이라도 보여주기
                    return raw;
                }

                const year = weekStart.getFullYear();
                const month = weekStart.getMonth() + 1; // 0~11 → 1~12

                // 월 첫날 기준으로 주차 계산 (월요일 기준으로 보정)
                const firstOfMonth = new Date(year, weekStart.getMonth(), 1);
                const firstDay = firstOfMonth.getDay(); // 0(일)~6(토)
                const offset = (firstDay + 6) % 7;      // 월요일을 0으로 맞추기

                const day = weekStart.getDate();
                const weekNo = Math.floor((day + offset - 1) / 7) + 1; // 1주차부터 시작

                return `${month}월 ${weekNo}주`;
            });
            const data = weeklyArray.map(item =>
                item && typeof item.joinCount === 'number' ? item.joinCount : 0
            );

            const maxVal = data.length > 0 ? Math.max(...data) : 0;

            window.joinweeklyChartInstance = new Chart(weeklyJoinChartEl.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '주별 가입자 수',
                        data: data,
                        borderColor: '#2196f3',
                        backgroundColor: 'rgba(33,150,243,0.2)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 1
                    }]
                },
                options: {
                    scales: {
                        x: {
                            grid: {
                                display: false
                            }
                        },
                        y: {
                            display: true,
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1,
                                precision: 0
                            },
                            suggestedMax: maxVal === 0 ? 1 : maxVal + 1
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                // 위쪽에 날짜 범위 노출 (2025.10.20 ~ 2025.10.26)
                                title: (context) => {
                                    const index = context[0].dataIndex;
                                    const item = weeklyArray[index];
                                    if (!item || !item.baseDate) return '';

                                    const raw = String(item.baseDate).replace(/^"|"$/g, '');
                                    const weekStart = new Date(raw);
                                    if (Number.isNaN(weekStart.getTime())) return raw;

                                    const weekEnd = new Date(weekStart);
                                    weekEnd.setDate(weekEnd.getDate() + 6);

                                    const fmt = (d) =>
                                        `${d.getFullYear()}.` +
                                        `${String(d.getMonth() + 1).padStart(2, '0')}.` +
                                        `${String(d.getDate()).padStart(2, '0')}`;

                                    return `${fmt(weekStart)} ~ ${fmt(weekEnd)}`;
                                },
                                // 아래쪽에 가입 건수 노출 (가입 10건)
                                label: (context) => {
                                    const value = context.parsed.y || 0;
                                    return `가입 ${value}건`;
                                }
                            }
                        }
                    },
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
        const monthlyJoinChartEl = document.getElementById('joinMonthlyChart');
        if (monthlyJoinChartEl) {
            const monthlyArray = Array.isArray(dataObj.monthlyJoinStats) ? dataObj.monthlyJoinStats : [];

            const labels = monthlyArray.map(item => {
                if (!item || !item.baseDate) return '';

                const raw = String(item.baseDate).replace(/"/g, '');
                if (/^\d{4}-\d{2}$/.test(raw)) {
                    return raw.substring(2).replace('-', '/');
                }
                return raw;
            });
            const data = monthlyArray.map(item =>
                item && typeof item.joinCount === 'number' ? item.joinCount : 0
            );

            const maxVal = data.length > 0 ? Math.max(...data) : 0;

            window.joinmonthlyChartInstance = new Chart(monthlyJoinChartEl.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '월별 가입자 수',
                        data: data,
                        borderColor: '#FF9800',
                        backgroundColor: 'rgba(255, 152, 0, 0.2)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3
                    }]
                },
                options: {
                    scales: {
                        x:{
                            grid:{
                                display: false
                            }
                        },
                        y: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1,
                                precision: 0
                            },
                            suggestedMax: maxVal === 0 ? 1 : maxVal + 1
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
        const ageChartEl = document.getElementById('ageChart');
        if (ageChartEl) {
            const ageArray = Array.isArray(dataObj.ageStats) ? dataObj.ageStats : [];

            const labels = ageArray.map(function (item) {
                if (!item || !item.ageBand) return '';
                return String(item.ageBand).replace(/^['"]+|['"]+$/g, '');
            });
            const counts = ageArray.map(item =>
                item && typeof item.count === 'number' ? item.count : 0
            );

            const maxVal = counts.length > 0 ? Math.max(...counts) : 0;

            const ctx = ageChartEl.getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '연령대별 회원 수',
                        data: counts,
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: {
                            ticks: {
                                font: { size: 11 }
                            },
                            grid: {
                                display: false
                            }
                        },
                        y: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1,
                                precision: 0,
                                font: { size: 11 }
                            },
                            suggestedMax: maxVal === 0 ? 1 : maxVal + 1
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    const value = context.parsed.y || 0;
                                    return value.toLocaleString('ko-KR') + '명';
                                }
                            }
                        }
                    }
                }
            });
        }
        (function () {
            const dataObj = window.dashboardData || {};
            const el = document.getElementById('genderChart');

            if (!el) {
                return;
            }

            if (typeof Chart === 'undefined') {
                console.warn('Chart.js가 로드되지 않았습니다. (genderChart)');
                return;
            }

            const array = Array.isArray(dataObj.genderStats) ? dataObj.genderStats : [];

            const labels = array.map(function (item) {
                if (!item || !item.gender) return '';

                // 문자열로 바꾼 후, 앞뒤의 ', " 제거
                return String(item.gender).replace(/^['"]+|['"]+$/g, '');
            });

            const values = array.map(function (item) {
                return item && typeof item.count === 'number' ? item.count : 0;
            });
            const baseColors = ['#7697fa', '#95afe4'];

            // 데이터 개수에 맞게 인덱스로 색 배정
            const backgroundColors = values.map(function (_, idx) {
                return baseColors[idx % baseColors.length];
            });

            const ctx = el.getContext('2d');

            if (window.genderChartInstance) {
                window.genderChartInstance.destroy();
            }

            window.genderChartInstance = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: backgroundColors,
                        hoverBackgroundColor: backgroundColors,
                        borderColor: '#ffffff',   // 가운데 하얀 경계선
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    animation: true,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'bottom',
                            labels: {
                                boxWidth: 16,
                                boxHeight: 16,
                                padding: 16
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    const label = context.label || '';
                                    const value = context.parsed || 0;
                                    const total = values.reduce(function (sum, v) { return sum + v; }, 0);
                                    const percent = total ? ((value / total) * 100).toFixed(1) : 0;
                                    return label + ': ' + value.toLocaleString('ko-KR') + '명 (' + percent + '%)';
                                }
                            }
                        }
                    }
                }
            });
        })();
    })();
});
