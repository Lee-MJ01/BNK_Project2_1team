/*
* 날짜 : 2025/11/20
* 이름 : 김대현
* 내용 : 약관 동의관련 수정
* */

let isIdChecked = false;     // 아이디 중복 확인 여부
let isEmailVerified = false; // 이메일 인증 여부
let isPhoneVerified = false; // 휴대폰 인증 여부

document.addEventListener("DOMContentLoaded", () => {

    /* ============================================================
       약관 동의 페이지 (member/terms.html) 로직
       ============================================================ */
    const agreeAll = document.getElementById('agreeAll');

    // 'agreeAll' 요소가 있는 페이지에서만 실행 (register.html 등에서는 무시됨)
    if (agreeAll) {
        // .terms-check 클래스 내부의 input 태그들 선택
        const checkboxes = document.querySelectorAll('.terms-check input');

        // 전체 동의 체크박스 이벤트
        agreeAll.addEventListener('change', () => {
            checkboxes.forEach(chk => chk.checked = agreeAll.checked);
        });

        // 개별 체크박스 클릭 시 전체 동의 상태 업데이트
        checkboxes.forEach(chk => {
            chk.addEventListener('change', () => {
                const allChecked = Array.from(checkboxes).every(c => c.checked);
                agreeAll.checked = allChecked;
            });
        });

        /*   "다음으로" 버튼 클릭 막기 추가  */
        const nextBtn = document.querySelector('.btn-next');

        if (nextBtn) {
            nextBtn.addEventListener('click', function(e) {
                if (!agreeAll.checked) {
                    e.preventDefault();
                    alert('모든 약관에 동의하셔야 다음 단계로 이동할 수 있습니다.');
                }
            });
        }



    }


    /* ============================================================
       회원가입 페이지 (member/register.html) - 아이디 중복 확인 로직
       ============================================================ */
    const idInput = document.getElementById('reg-custId');

    if (idInput) {
        const idCheckBtn = idInput.parentElement.querySelector('#id-check-btn');

        if (idCheckBtn) {
            idCheckBtn.addEventListener('click', function() {
                const custId = idInput.value.trim();

                if (!custId) {
                    alert("아이디를 입력해주세요.");
                    idInput.focus();
                    return;
                }

                fetch('/flobank/member/checkId', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'custId=' + encodeURIComponent(custId)
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('네트워크 응답에 문제가 있습니다.');
                        }
                        return response.json();
                    })
                    .then(isDuplicated => {
                        if (isDuplicated) {
                            alert("이미 사용 중인 아이디입니다.");
                            idInput.value = "";
                            idInput.focus();
                            isIdChecked = false;
                        } else {
                            alert("사용 가능한 아이디입니다.");
                            isIdChecked = true;
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert("중복 확인 중 오류가 발생했습니다.");
                    });
            });
            idInput.addEventListener('input', () => {
                // 아이디를 다시 입력하면 중복 확인 상태 초기화
                isIdChecked = false;
            });
        }
    }

    /* ============================================================
       회원가입 페이지 (member/register.html) - 비밀번호 일치 확인 로직
       ============================================================ */
    const pwInput = document.getElementById('custPw');
    const pwConfirmInput = document.getElementById('custPwConfirm');

    // 비밀번호 입력창들이 존재하는 경우에만 실행
    if (pwInput && pwConfirmInput) {

        // 1. 메시지를 표시할 요소(span)를 동적으로 생성하여 input 아래에 추가
        const msgSpan = document.createElement('div');
        msgSpan.style.fontSize = '13px';
        msgSpan.style.marginTop = '5px';
        msgSpan.style.fontWeight = '500';

        // custPwConfirm의 부모 요소(.form-group)에 메시지 박스 추가
        pwConfirmInput.parentElement.appendChild(msgSpan);

        // 2. 비밀번호 검증 함수
        function checkPasswordMatch() {
            const pw = pwInput.value;
            const confirmPw = pwConfirmInput.value;

            // 아직 확인란에 아무것도 안 썼으면 메시지 안 띄움
            if (confirmPw === '') {
                msgSpan.textContent = '';
                return;
            }

            // 일치 여부 확인
            if (pw === confirmPw) {
                msgSpan.textContent = '비밀번호가 일치합니다.';
                msgSpan.style.color = '#4A6FA5'; // 파란색 (성공)
            } else {
                msgSpan.textContent = '비밀번호가 일치하지 않습니다.';
                msgSpan.style.color = '#E53935'; // 빨간색 (실패)
            }
        }

        // 3. 두 입력창에 'input' 이벤트(타이핑 할 때마다) 연결
        pwInput.addEventListener('input', checkPasswordMatch);
        pwConfirmInput.addEventListener('input', checkPasswordMatch);
    }

    /* ============================================================
       회원가입 페이지 (member/register.html) - 주민등록번호 유효성 검사 (숫자만 & 13자리 체크)
       ============================================================ */
    const juminInput = document.getElementById('custJumin');

    if (juminInput) {
        // 1. 메시지 표시할 div 생성
        const juminMsg = document.createElement('div');
        juminMsg.style.fontSize = '13px';
        juminMsg.style.marginTop = '5px';
        juminMsg.style.fontWeight = '500';

        // input 태그 바로 아래(부모 요소 내부)에 추가
        juminInput.parentElement.appendChild(juminMsg);

        // 2. 입력값 검증 함수
        function validateJumin() {
            // 숫자 이외 제거
            let val = juminInput.value.replace(/[^0-9]/g, '');

            // 13자리 초과 시 처리 (잘라내기 & 경고)
            if (val.length > 13) {
                val = val.slice(0, 13); // 강제로 13자리로 맞춤
            } else if (val.length < 13 && val.length > 0) {
                // 입력 중이지만 13자리 미만일 때
                juminMsg.textContent = '13자리 모두 입력해주세요.';
                juminMsg.style.color = '#E53935'; // 빨간색
            } else if (val.length === 13) {
                // 정확히 13자리일 때
                juminMsg.textContent = '입력 완료';
                juminMsg.style.color = '#4A6FA5'; // 파란색 (성공)
            } else {
                // 비어있을 때
                juminMsg.textContent = '';
            }

            // 정제된 값(숫자만, 13자리 이하)을 다시 입력창에 반영
            juminInput.value = val;
        }

        // 3. 이벤트 리스너 연결
        // 'input': 타이핑할 때마다 실시간 검사
        juminInput.addEventListener('input', validateJumin);

        // 'blur': 포커스가 나갈 때 다시 한 번 확인 (미완성 상태 경고 유지)
        juminInput.addEventListener('blur', validateJumin);
    }

    /* ============================================================
       회원가입 페이지 - 다음 주소 찾기 API 연동
       ============================================================ */
    const zipBtn = document.getElementById('zip-btn');

    if (zipBtn) {
        zipBtn.addEventListener('click', function() {
            new daum.Postcode({
                oncomplete: function(data) {
                    // 1. 주소 변수 (도로명/지번)
                    var addr = '';
                    var extraAddr = '';

                    // 2. 사용자가 선택한 주소 타입에 따라 주소 값 가져오기
                    if (data.userSelectedType === 'R') { // 도로명 주소
                        addr = data.roadAddress;
                    } else { // 지번 주소
                        addr = data.jibunAddress;
                    }

                    // 3. 참고항목(동/로/가) 조합 (도로명일 경우에만)
                    if(data.userSelectedType === 'R'){
                        if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                            extraAddr += data.bname;
                        }
                        if(data.buildingName !== '' && data.apartment === 'Y'){
                            extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                        }
                        // 참고항목이 있다면 괄호로 감싸서 주소 뒤에 붙임
                        if(extraAddr !== ''){
                            addr += ' (' + extraAddr + ')';
                        }
                    }

                    // 4. 입력창에 값 넣기
                    // 우편번호
                    document.getElementById('custZip').value = data.zonecode;
                    // 기본주소
                    document.getElementById('custAddr1').value = addr;

                    // 5. 상세주소로 포커스 이동
                    document.getElementById('custAddr2').focus();
                }
            }).open();
        });
    }

    /* ============================================================
           회원가입 페이지 - 휴대폰 인증
   ============================================================ */
    const btnSendSms = document.querySelector('#btnSendCode');
    const btnVerifySms = document.querySelector('#btnVerifyCode'); // ✅ 수정됨 (ID로 변경)
    const inputPhone = document.querySelector('#custHp');
    const inputSmsCode = document.querySelector('#verifyCodeInput'); // ✅ 수정됨 (ID로 변경)

    if (btnSendSms && btnVerifySms) {
        btnSendSms.addEventListener('click', async function (e) {
            e.preventDefault();
            const phone = inputPhone.value.trim();

            if (!validatePhone(phone)) return; // 유효성 검사

            btnSendSms.disabled = true;
            btnSendSms.textContent = '전송중...';

            try {
                const response = await fetch(`/flobank/sms/send?phoneNumber=${encodeURIComponent(phone)}`, { method: 'POST' });

                if (!response.ok) {
                    const errorData = await response.json(); // 백엔드에서 에러 메시지를 보낸다면
                    console.error("SMS Error Data:", errorData);
                    throw new Error(errorData.message || 'SMS 전송 실패');
                }

                alert('인증번호가 전송되었습니다.');

                // 👇 [수정] 인증번호 입력창과 확인 버튼을 보여줍니다.
                inputSmsCode.style.display = 'inline-block';
                btnVerifySms.style.display = 'inline-block';
                inputSmsCode.focus(); // 인증번호 입력창에 포커스

                btnSendSms.textContent = '재전송';

            } catch (err) {
                console.error('SMS Send Error:', err);
                alert(`SMS 전송 중 오류 발생: ${err.message}`);
            } finally {
                btnSendSms.disabled = false; // 재전송 가능하도록 활성화
            }
        });

        btnVerifySms.addEventListener('click', async function (e) {
            e.preventDefault();
            const phone = inputPhone.value.trim();
            const code = inputSmsCode.value.trim();

            if (!phone || !code) {
                alert('전화번호와 인증번호를 입력해주세요.');
                return;
            }

            try {
                const response = await fetch(`/flobank/sms/verify?phoneNumber=${encodeURIComponent(phone)}&code=${encodeURIComponent(code)}`, { method: 'POST' });
                const isValid = await response.json();

                if (isValid) {
                    alert('휴대폰 인증 완료!');

                    // 👇 [추가] 인증 완료 상태로 변경
                    isPhoneVerified = true;

                    // 필드 및 버튼 비활성화
                    inputPhone.readOnly = true;
                    inputSmsCode.readOnly = true;
                    btnSendSms.disabled = true; // 재전송 버튼도 비활성화
                    btnVerifySms.disabled = true;
                    btnVerifySms.textContent = '인증완료';
                } else {
                    alert('인증번호가 일치하지 않습니다.');
                    isPhoneVerified = false; // 인증 실패
                }
            } catch (err) {
                console.error('SMS Verify Error:', err);
                alert('인증 확인 중 오류 발생');
                isPhoneVerified = false;
            }
        });
    }

    /* ============================================================
               회원가입 페이지 - 메일 인증
       ============================================================ */
    // 1. 이메일 인증용 요소 선택 (HTML에서 새로 추가한 ID 기준)
    const btnSendEmail = document.querySelector('#btnSendEmailCode');
    const btnVerifyEmail = document.querySelector('#btnVerifyEmailCode');
    const inputEmail = document.querySelector('#custEmail');
    const inputEmailCode = document.querySelector('#emailVerifyCodeInput');
    const emailVerifyBox = document.querySelector('#emailVerifyBox'); // 인증번호 입력 영역

// 2. 이메일 인증 관련 이벤트 리스너 추가
    if (btnSendEmail && btnVerifyEmail && inputEmail) {

        // [이메일 인증번호 전송] 버튼 클릭
        btnSendEmail.addEventListener('click', async function (e) {
            e.preventDefault();
            const email = inputEmail.value.trim();

            // 이메일 유효성 검사
            if (!validateEmail(email)) {
                return;
            }

            btnSendEmail.disabled = true;
            btnSendEmail.textContent = '전송중...';

            try {
                const response = await fetch(`/flobank/email/send?email=${encodeURIComponent(email)}`, { method: 'POST' });

                if (!response.ok) {
                    throw new Error('이메일 전송에 실패했습니다.');
                }

                alert('인증번호가 전송되었습니다.');

                // 인증번호 입력창과 확인 버튼을 보여줍니다.
                emailVerifyBox.style.display = 'flex'; // (div 자체를 보여줌)
                inputEmailCode.focus(); // 인증번호 입력창에 포커스
                btnSendEmail.textContent = '재전송';

            } catch (err) {
                console.error('Email Send Error:', err);
                alert(`이메일 전송 중 오류 발생: ${err.message}`);
            } finally {
                btnSendEmail.disabled = false; // 재전송 가능하도록 활성화
            }
        });

        // [이메일 인증번호 확인] 버튼 클릭
        btnVerifyEmail.addEventListener('click', async function (e) {
            e.preventDefault();
            const email = inputEmail.value.trim();
            const code = inputEmailCode.value.trim();

            if (!email || !code) {
                alert('이메일 주소와 인증번호를 입력해주세요.');
                return;
            }

            try {
                const response = await fetch(`/flobank/email/verify?email=${encodeURIComponent(email)}&code=${encodeURIComponent(code)}`, { method: 'POST' });
                const isValid = await response.json(); // 백엔드에서 true/false 반환 가정

                if (isValid) {
                    alert('이메일 인증 완료!');
                    isEmailVerified = true; // 전역 변수 상태 변경

                    // 필드 및 버튼 비활성화
                    inputEmail.readOnly = true;
                    inputEmailCode.readOnly = true;
                    btnSendEmail.disabled = true; // 재전송 버튼도 비활성화
                    btnVerifyEmail.disabled = true;
                    btnVerifyEmail.textContent = '인증완료';
                } else {
                    alert('인증번호가 일치하지 않습니다.');
                    isEmailVerified = false; // 인증 실패
                }
            } catch (err) {
                console.error('Email Verify Error:', err);
                alert('인증 확인 중 오류 발생');
                isEmailVerified = false;
            }
        });
    }

    /* ============================================================
           폼 제출(Submit) 시 최종 유효성 검사
       ============================================================ */
    const joinForm = document.querySelector('form.join-form');

    if (joinForm) {
        joinForm.addEventListener('submit', function(e) {

            // 1. 아이디 중복 확인 검사
            if (!isIdChecked) {
                e.preventDefault(); // 폼 제출 중단
                alert('아이디 중복 확인을 해주세요.');
                document.getElementById('reg-custId').focus();
                return;
            }

            // 2. 이메일 인증 검사
            if (!isEmailVerified) {
                e.preventDefault(); // 폼 제출 중단
                alert('이메일 인증을 완료해주세요.');
                document.getElementById('custEmail').focus();
                return;
            }

            // 3. 휴대폰 인증 검사
            if (!isPhoneVerified) {
                e.preventDefault(); // 폼 제출 중단
                alert('휴대폰 인증을 완료해주세요.');
                document.getElementById('custHp').focus();
                return;
            }

            // 4. 비밀번호 일치 여부 최종 확인
            const pw = document.getElementById('custPw').value;
            const pwConfirm = document.getElementById('custPwConfirm').value;
            if (pw !== pwConfirm) {
                e.preventDefault(); // 폼 제출 중단
                alert('비밀번호가 일치하지 않습니다.');
                document.getElementById('custPwConfirm').focus();
                return;
            }

        });
    }

});

/**
 * 휴대폰 번호 유효성 검사
 */
function validatePhone(phone) {
    const phonePattern = /^01[0-9]\d{7,8}$/; // 01X + 7~8자리 숫자 (총 10~11자리)

    if (!phone) {
        alert('휴대폰 번호를 입력해주세요.');
        document.querySelector('#custHp').focus();
        return false;
    }

    if (!phonePattern.test(phone)) {
        alert('올바른 휴대폰 번호 형식이 아닙니다. (예: 010-1234-5678)');
        document.querySelector('#custHp').focus();
        return false;
    }

    return true;
}

/**
 * 이메일 유효성 검사
 */
function validateEmail(email) {
    const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    if (!email) {
        alert('이메일을 입력해주세요.');
        document.querySelector('#custEmail').focus();
        return false;
    }
    if (!emailPattern.test(email)) {
        alert('올바른 이메일 형식이 아닙니다.');
        document.querySelector('#custEmail').focus();
        return false;
    }
    return true;
}