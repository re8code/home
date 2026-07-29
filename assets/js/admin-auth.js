// 원장 전용 기능("수정", "삭제", "글 작성") 접근 시 사용하는 인증 게이트.
// firebase-config.js가 실제 프로젝트 값으로 설정된 경우 Firebase Authentication으로
// 실제 로그인을 수행하고, 아직 임시(placeholder) 값인 개발 단계에서는 로컬 비밀번호로
// 대체하여 Firebase 프로젝트 없이도 화면 동작을 확인할 수 있게 합니다.
import { IS_PLACEHOLDER_CONFIG } from './firebase-config.js';
import { isAdminSignedIn, signInAdmin } from './firebase-auth.js';

// 개발 단계(임시 config)에서만 쓰이는 로컬 비밀번호. 실제 config로 교체되면 이 값은
// 더 이상 쓰이지 않고, Firebase Authentication에 등록한 계정 비밀번호가 사용됩니다.
const DEV_FALLBACK_PASSWORD = 'sungwons';

async function verifyAdminPassword(password) {
  if (IS_PLACEHOLDER_CONFIG) {
    return password === DEV_FALLBACK_PASSWORD;
  }
  return signInAdmin(password);
}

// 비밀번호 입력 모달을 띄우고, 인증 성공 시 true / 취소·실패 시 false를 resolve합니다.
// 이미 Firebase Authentication에 원장으로 로그인되어 있는 경우(같은 브라우저에서 재방문 등)
// 모달 없이 즉시 true를 반환합니다.
export function requestAdminPassword(actionLabel) {
  if (!IS_PLACEHOLDER_CONFIG && isAdminSignedIn()) {
    return Promise.resolve(true);
  }

  return new Promise((resolve) => {
    const overlay = document.createElement('div');
    overlay.className =
      'fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/60 backdrop-blur-sm px-4';
    overlay.innerHTML = `
      <div class="w-full max-w-sm rounded-2xl border border-slate-900/10 bg-white p-6 shadow-xl">
        <h3 class="text-base font-semibold text-slate-900">원장 인증</h3>
        <p class="mt-1 text-sm text-slate-500">"${actionLabel}" 기능은 원장만 사용할 수 있습니다. 비밀번호를 입력해주세요.</p>
        <input type="password" class="admin-pw-input mt-4 w-full rounded-xl border border-slate-900/10 px-4 py-2.5 text-sm focus:outline-none focus:border-brand-500/50" placeholder="비밀번호" autocomplete="off" />
        <p class="admin-pw-error mt-2 hidden text-xs text-red-500">비밀번호가 올바르지 않습니다.</p>
        <div class="mt-5 flex justify-end gap-2">
          <button type="button" class="admin-pw-cancel rounded-full px-4 py-2 text-sm text-slate-500 hover:bg-slate-900/5">취소</button>
          <button type="button" class="admin-pw-confirm rounded-full bg-brand-500 px-4 py-2 text-sm font-semibold text-slate-950 hover:bg-brand-400">확인</button>
        </div>
      </div>`;
    document.body.appendChild(overlay);

    const input = overlay.querySelector('.admin-pw-input');
    const errorEl = overlay.querySelector('.admin-pw-error');
    const confirmBtn = overlay.querySelector('.admin-pw-confirm');
    input.focus();

    function close(result) {
      overlay.remove();
      resolve(result);
    }

    async function submit() {
      confirmBtn.disabled = true;
      confirmBtn.textContent = '확인 중...';
      const ok = await verifyAdminPassword(input.value);
      if (ok) {
        close(true);
      } else {
        errorEl.classList.remove('hidden');
        input.value = '';
        input.focus();
        confirmBtn.disabled = false;
        confirmBtn.textContent = '확인';
      }
    }

    overlay.querySelector('.admin-pw-confirm').addEventListener('click', submit);
    overlay.querySelector('.admin-pw-cancel').addEventListener('click', () => close(false));
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') submit();
      if (e.key === 'Escape') close(false);
    });
  });
}

// 스타일이 통일된 확인 모달(네이티브 confirm() 대체).
export function confirmAction(message) {
  return new Promise((resolve) => {
    const overlay = document.createElement('div');
    overlay.className =
      'fixed inset-0 z-[100] flex items-center justify-center bg-slate-950/60 backdrop-blur-sm px-4';
    overlay.innerHTML = `
      <div class="w-full max-w-sm rounded-2xl border border-slate-900/10 bg-white p-6 shadow-xl">
        <p class="text-sm text-slate-700 leading-relaxed">${message}</p>
        <div class="mt-5 flex justify-end gap-2">
          <button type="button" class="confirm-cancel rounded-full px-4 py-2 text-sm text-slate-500 hover:bg-slate-900/5">취소</button>
          <button type="button" class="confirm-ok rounded-full bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-400">삭제</button>
        </div>
      </div>`;
    document.body.appendChild(overlay);

    function close(result) {
      overlay.remove();
      resolve(result);
    }

    overlay.querySelector('.confirm-ok').addEventListener('click', () => close(true));
    overlay.querySelector('.confirm-cancel').addEventListener('click', () => close(false));
  });
}
