document.addEventListener("DOMContentLoaded", () => {
    // 1. HTML에 숨겨진 데이터 태그 가져오기
    const dataEl = document.getElementById("eventData");

    // dataset을 통해 값 추출
    const joinDateStr = dataEl.dataset.joinDate;
    const listStr = dataEl.dataset.attendanceList;
    const message = dataEl.dataset.message;
    const hasAttendedStr = dataEl.dataset.hasAttended;

    // [추가] 14일 달성 여부 & 쿠폰 여부 가져오기
    const isGoalReachedStr = dataEl.dataset.isGoalReached;
    const hasCouponStr = dataEl.dataset.hasCoupon;

    const imgGray = dataEl.dataset.imgGray;
    const imgColor = dataEl.dataset.imgColor;


    // 쿠폰 발급
    const couponUrl = dataEl.dataset.couponUrl;


    // Boolean 변환
    const hasAttendedToday = (hasAttendedStr === 'true');
    const isGoalReached = (isGoalReachedStr === 'true');
    const hasCoupon = (hasCouponStr === 'true');

    const attendanceList = listStr ? listStr.split(',') : [];

    // 2. 알림 메시지 처리
    if (message) {
        alert(message);
    }

    const grid = document.getElementById("attendanceGrid");
    const checkBtn = document.getElementById("checkBtn");
    const checkInForm = document.getElementById("checkInForm");

    const joinDate = new Date(joinDateStr);
    const totalDays = 14;

    // 3. 그리드 그리기 (기존과 동일)
    for (let i = 0; i < totalDays; i++) {
        const currentDate = new Date(joinDate);
        currentDate.setDate(joinDate.getDate() + i);

        const yyyy = currentDate.getFullYear();
        const mm = String(currentDate.getMonth() + 1).padStart(2, '0');
        const dd = String(currentDate.getDate()).padStart(2, '0');
        const dateString = `${yyyy}${mm}${dd}`;

        const displayDate = `${currentDate.getMonth() + 1}/${currentDate.getDate()}`;
        const isChecked = attendanceList.includes(dateString);

        const dayEl = document.createElement("div");
        dayEl.classList.add("eventpage-box");

        const img = document.createElement("img");
        img.src = isChecked ? imgColor : imgGray;
        if (isChecked) {
            img.classList.add("checked");
        }

        const label = document.createElement("p");
        label.textContent = displayDate;

        dayEl.appendChild(img);
        dayEl.appendChild(label);
        grid.appendChild(dayEl);
    }

    // 4. [중요] 버튼 상태 및 클릭 이벤트 제어
    if (checkBtn) {

        // (A) 버튼 상태 결정 (우선순위: 쿠폰보유 > 14일달성 > 오늘출석 > 기본)
        if (hasCoupon) {
            checkBtn.textContent = "쿠폰 발급 완료";
            checkBtn.disabled = true; // 클릭 불가
            checkBtn.style.backgroundColor = "#ccc"; // 회색 처리
        } else if (isGoalReached) {
            // 14일 다 채웠고 아직 쿠폰 안 받은 상태
            checkBtn.textContent = "🎁 쿠폰 발급받기";
        } else if (hasAttendedToday) {
            checkBtn.textContent = "오늘 출석 완료";
        } else {
            checkBtn.textContent = "오늘 출석하기";
        }

        // (B) 클릭 이벤트
        checkBtn.addEventListener("click", () => {
            if (hasCoupon) return;

            if (isGoalReached) {
                // [수정] 하드코딩된 주소 대신 couponUrl 변수 사용
                fetch(couponUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" }
                })
                    .then(response => response.json())
                    .then(data => {
                        alert(data.message);
                        if (data.success) {
                            location.reload();
                        }
                    })
                    .catch(error => {
                        console.error("Error:", error);
                        alert("통신 중 오류가 발생했습니다.");
                    });
                return;
            }



            // 2. [수정됨] 14일 달성 시 -> AJAX로 쿠폰 발급 요청
            if (isGoalReached) {

                // fetch 요청 보내기
                fetch("/mypage/event/coupon", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    }
                    // Spring Security CSRF 설정이 있다면 토큰 헤더 추가 필요 (보통은 생략 가능하거나 meta태그 이용)
                })
                    .then(response => response.json()) // 이제 JSON이 오므로 에러 안 남!
                    .then(data => {
                        // 서버 메시지 알림 ("축하합니다..." 또는 에러메시지)
                        alert(data.message);

                        if (data.success) {
                            // 성공하면 페이지 새로고침 -> 버튼이 [발급 완료]로 바뀜
                            location.reload();
                        }
                    })
                    .catch(error => {
                        console.error("Error:", error);
                        alert("통신 중 오류가 발생했습니다.");
                    });

                return; // 폼 전송 막고 종료
            }


            // 3. 일반 출석 체크 로직
            if (hasAttendedToday) {
                alert("오늘은 이미 출석하셨습니다!");
                return;
            }

            // 날짜 유효성 검사
            const today = new Date();
            const todayOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());
            const joinOnly = new Date(joinDate.getFullYear(), joinDate.getMonth(), joinDate.getDate());
            const diffTime = todayOnly - joinOnly;
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays < 0) {
                alert("아직 이벤트 시작일이 아닙니다!");
                return;
            }
            if (diffDays >= totalDays) {
                alert("이벤트 기간(14일)이 종료되었습니다.");
                return;
            }

            // 일반 출석 요청 전송
            checkInForm.submit();
        });
    }
});