const aiNoticeText = "AI 생성 초안입니다. 검토가 필요합니다.";

// ✅ 여기 한 줄 추가 (context-path 고정)
const BASE_PATH = '/flobank';

document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('qnaModal');
    const closeBtn = modal?.querySelector('.qna-modal-close');
    const questionEl = document.getElementById('qnaModalQuestion');
    const titleEl = document.getElementById('qnaModalTitle');
    const metaEl = document.getElementById('qnaModalMeta');
    const statusEl = document.getElementById('qnaModalStatus');
    const replyField = document.getElementById('qnaReplyInput');
    const hintEl = document.getElementById('qnaModalAiHint');
    const saveBtn = document.getElementById('qnaSaveButton');
    const cancelBtn = document.getElementById('qnaCancelButton');
    const deleteBtn = document.getElementById('qnaDeleteButton');

    let currentQnaNo = null;
    let currentStatus = 'WAIT';

    const escapeHtml = (value = '') =>
        value
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');

    const formatMultiline = (value = '') => escapeHtml(value).replace(/\n/g, '<br>');

    const isAnsweredStatus = (status) => {
        const upper = (status || '').toUpperCase();
        return upper === 'SAFE' || upper === 'ANSWERED';
    };

    const setStatusBadge = (status) => {
        if (!statusEl) return;
        const normalized = (status || 'WAIT').toLowerCase();
        statusEl.className = `qna-status ${normalized}`;
        statusEl.textContent = isAnsweredStatus(status) ? '답변완료' : '답변준비중';
    };

    const setAiHintVisibility = (status, text) => {
        if (!hintEl) return;
        const showHint = !isAnsweredStatus(status) && (text || '').includes(aiNoticeText);
        hintEl.style.display = showHint ? 'block' : 'none';
    };

    const openModal = () => {
        if (!modal) return;
        modal.style.display = 'block';
        modal.setAttribute('aria-hidden', 'false');
    };

    const closeModal = () => {
        if (!modal) return;
        modal.style.display = 'none';
        modal.setAttribute('aria-hidden', 'true');
        if (replyField) {
            replyField.value = '';
        }
        currentQnaNo = null;
        currentStatus = 'WAIT';
    };

    const getCurrentUrlForReload = () => {
        const { href } = window.location;
        return href.includes('#') ? href : `${href}#qna-list`;
    };

    const fillModal = (data) => {
        currentQnaNo = data.qnaNo;
        currentStatus = data.qnaStatus || 'WAIT';

        if (titleEl) {
            titleEl.textContent = data.qnaTitle || 'Q&A 상세';
        }

        if (metaEl) {
            const namePart = data.qnaCustName || data.qnaCustCode || '작성자 정보 없음';
            const datePart = data.qnaDt ? new Date(data.qnaDt).toLocaleString() : '';
            metaEl.textContent = `${namePart}${datePart ? ' · ' + datePart : ''}`;
        }

        if (questionEl) {
            const questionText = data.qnaContent && data.qnaContent.trim().length > 0
                ? formatMultiline(data.qnaContent)
                : '등록된 내용이 없습니다.';
            questionEl.innerHTML = questionText;
        }

        const answered = isAnsweredStatus(currentStatus);
        const replyValue = answered ? data.qnaReply : (data.qnaDraft || data.qnaReply || '');

        if (replyField) {
            replyField.value = replyValue || '';
        }

        setStatusBadge(currentStatus);
        setAiHintVisibility(currentStatus, replyValue);
    };

    const fetchJson = async (url, options = {}) => {
        const response = await fetch(url, options);
        const data = await response.json().catch(() => ({}));
        return { ok: response.ok, data };
    };

    const openQna = async (qnaNo) => {
        if (!qnaNo) return;
        // ✅ /flobank 붙여서 호출
        const { ok, data } = await fetchJson(`${BASE_PATH}/admin/api/qna/${qnaNo}`);
        if (!ok) {
            alert('문의 정보를 불러오지 못했습니다.');
            return;
        }
        fillModal(data);
        openModal();
    };

    const saveReply = async () => {
        if (!currentQnaNo) return;
        const params = new URLSearchParams();
        params.append('reply', replyField?.value ?? '');

        const { ok, data } = await fetchJson(`${BASE_PATH}/admin/api/qna/${currentQnaNo}/reply`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        });

        if (!ok) {
            alert(data.message || '답변 저장 중 오류가 발생했습니다.');
            return;
        }

        alert(data.message || '답변이 저장되었습니다.');
        closeModal();
        window.location.href = getCurrentUrlForReload();
    };

    const deleteQna = async () => {
        if (!currentQnaNo || !confirm('정말 삭제하시겠습니까?')) return;

        const { ok, data } = await fetchJson(`${BASE_PATH}/admin/api/qna/${currentQnaNo}`, {
            method: 'DELETE'
        });

        if (!ok) {
            alert(data.message || '삭제 중 오류가 발생했습니다.');
            return;
        }

        alert(data.message || '삭제되었습니다.');
        closeModal();
        window.location.href = getCurrentUrlForReload();
    };

    document.querySelectorAll('.qna-btn-view[data-qna-no]')
        .forEach((btn) => btn.addEventListener('click', (e) => {
            e.preventDefault();
            const qnaNo = btn.getAttribute('data-qna-no');
            openQna(qnaNo);
        }));

    closeBtn?.addEventListener('click', closeModal);
    cancelBtn?.addEventListener('click', closeModal);
    saveBtn?.addEventListener('click', saveReply);
    deleteBtn?.addEventListener('click', deleteQna);

    modal?.addEventListener('click', (event) => {
        if (event.target === modal) {
            closeModal();
        }
    });
});
