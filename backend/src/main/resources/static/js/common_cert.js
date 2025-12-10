const CertManager = {
    checkInterval: null,
    popupWindow: null,
    onSuccess: null,

    /**
     * 인증 요청 시작
     * @param {string} title - 인증창에 띄울 거래 제목 (예: '환전신청')
     * @param {string} amount - 인증창에 띄울 금액 (예: '1,000,000')
     * @param {function} callback - 인증 완료 후 실행할 함수
     */
    request: function(title, amount, callback) {
        this.onSuccess = callback;

        // 1. 서버에 인증 세션 초기화 요청
        fetch('/flobank/api/cert/init', { method: 'POST' })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    // 2. 팝업창 열기 (가상 카카오톡)
                    const width = 340;
                    const height = 550;
                    const left = (window.screen.width - width) / 2;
                    const top = (window.screen.height - height) / 2;

                    // URL에 정보 전달 (GET 파라미터)
                    const url = `/flobank/mock/kakao/auth?title=${encodeURIComponent(title)}&amount=${amount}`;

                    this.popupWindow = window.open(url, 'KakaoAuth', `width=${width},height=${height},top=${top},left=${left}`);

                    // 3. 폴링 시작 (인증 완료됐는지 주기적으로 확인)
                    this.startPolling();
                }
            });
    },

    startPolling: function() {
        if (this.checkInterval) clearInterval(this.checkInterval);

        this.checkInterval = setInterval(() => {
            // 팝업이 닫혔는지 확인
            if (this.popupWindow && this.popupWindow.closed) {
                clearInterval(this.checkInterval);
                // 팝업이 그냥 닫혔을 수도 있으니 마지막으로 확인하거나, 사용자에게 알림
                console.log("인증창이 닫혔습니다.");
                return;
            }

            // 서버에 상태 확인
            fetch('/flobank/api/cert/check')
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'complete') {
                        // 인증 완료!
                        clearInterval(this.checkInterval);
                        if (this.popupWindow) this.popupWindow.close();

                        // 콜백 실행
                        if (this.onSuccess) this.onSuccess();
                    }
                });
        }, 1000); // 1초마다 확인
    }
};