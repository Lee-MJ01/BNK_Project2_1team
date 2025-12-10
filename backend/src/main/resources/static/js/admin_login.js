// 휴대폰 인증 완료 여부
let isPhoneVerified = false;

document.addEventListener("DOMContentLoaded", () => {

    const btnSendSms   = document.getElementById('btnSendCode');   // 버튼 id
    const btnVerifySms = document.getElementById('btnVerifyCode'); // 버튼 id
    const inputPhone   = document.getElementById('phone');         // input id
    const inputSmsCode = document.getElementById('code');          // input id
    const loginForm    = document.querySelector('form');           // 이 페이지 폼 하나라고 가정

    console.log('[admin_login] loaded', { btnSendSms, btnVerifySms, inputPhone, inputSmsCode });

    // 필수 요소가 없으면 바로 로그 찍고 종료
    if (!btnSendSms || !btnVerifySms || !inputPhone || !inputSmsCode) {
        console.warn('[admin_login] 필수 요소 못 찾음. id 확인 필요');
        return;
    }

    /* 1. 인증번호 발송 */
    btnSendSms.addEventListener('click', async function (e) {
        e.preventDefault();

        const phone = inputPhone.value.trim();
        if (!validateAdminPhone(phone)) return;

        btnSendSms.disabled = true;
        btnSendSms.textContent = '전송중...';

        try {
            // 회원가입 로직과 동일: /flobank/sms/send
            const res = await fetch(`/flobank/sms/send?phoneNumber=${encodeURIComponent(phone)}`, {
                method: 'POST'
            });

            if (!res.ok) {
                let errData = null;
                try { errData = await res.json(); } catch (_) {}
                throw new Error(errData?.message || 'SMS 전송 실패');
            }

            alert('인증번호가 전송되었습니다.');
            inputSmsCode.focus();
            btnSendSms.textContent = '재전송';

        } catch (err) {
            console.error('SMS Send Error:', err);
            alert(`SMS 전송 중 오류: ${err.message}`);
        } finally {
            btnSendSms.disabled = false;
        }
    });

    /* 2. 인증번호 검증 */
    btnVerifySms.addEventListener('click', async function (e) {
        e.preventDefault();

        const phone = inputPhone.value.trim();
        const code  = inputSmsCode.value.trim();

        if (!phone || !code) {
            alert('전화번호와 인증번호를 입력해주세요.');
            return;
        }

        try {
            const res = await fetch(
                `/flobank/sms/verify?phoneNumber=${encodeURIComponent(phone)}&code=${encodeURIComponent(code)}`,
                { method: 'POST' }
            );

            const isValid = await res.json(); // boolean

            if (isValid) {
                alert('휴대폰 인증 완료!');
                isPhoneVerified = true;

                inputPhone.readOnly   = true;
                inputSmsCode.readOnly = true;
                btnSendSms.disabled   = true;
                btnVerifySms.disabled = true;
                btnVerifySms.textContent = '인증완료';
            } else {
                alert('인증번호가 올바르지 않거나 만료되었습니다.');
                isPhoneVerified = false;
            }

        } catch (err) {
            console.error('SMS Verify Error:', err);
            alert('인증 확인 중 오류 발생');
            isPhoneVerified = false;
        }
    });

    /* 3. 로그인 submit 시 인증 완료 체크 */
    if (loginForm) {
        loginForm.addEventListener('submit', function (e) {
            if (!isPhoneVerified) {
                e.preventDefault();
                alert('휴대폰 인증을 먼저 완료해주세요.');
                inputPhone.focus();
            }
        });
    }
});

/* 휴대폰 번호 형식 체크 */
function validateAdminPhone(phone) {
    const phonePattern = /^01[0-9]\d{7,8}$/; // 01012345678

    if (!phone) {
        alert('휴대폰 번호를 입력해주세요.');
        document.getElementById('phone')?.focus();
        return false;
    }

    if (!phonePattern.test(phone)) {
        alert('올바른 휴대폰 번호 형식이 아닙니다. (예: 01012345678)');
        document.getElementById('phone')?.focus();
        return false;
    }

    return true;
}
