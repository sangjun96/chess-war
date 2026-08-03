(function () {
  var stage = document.getElementById('game-stage');
  var canvas = document.getElementById('canvas');
  var fullscreenButton = document.getElementById('fullscreen-button');
  var helpButton = document.getElementById('help-button');
  var helpClose = document.getElementById('help-close');
  var guide = document.getElementById('control-guide');

  function fullscreenElement() {
    return document.fullscreenElement || document.webkitFullscreenElement;
  }

  function updateFullscreenButton() {
    var active = fullscreenElement() === stage || stage.classList.contains('focus-mode');
    fullscreenButton.textContent = active ? '×' : '⛶';
    fullscreenButton.setAttribute('aria-label', active ? '전체화면 종료' : '전체화면 시작');
  }

  function leaveFocusMode() {
    stage.classList.remove('focus-mode');
    document.body.classList.remove('game-focused');
  }

  async function toggleFullscreen() {
    try {
      if (stage.classList.contains('focus-mode')) {
        leaveFocusMode();
      } else if (fullscreenElement()) {
        await (document.exitFullscreen ? document.exitFullscreen() : document.webkitExitFullscreen());
      } else if (stage.requestFullscreen) {
        await stage.requestFullscreen();
      } else if (stage.webkitRequestFullscreen) {
        stage.webkitRequestFullscreen();
      } else {
        stage.classList.toggle('focus-mode');
        document.body.classList.toggle('game-focused', stage.classList.contains('focus-mode'));
      }
    } catch (_) {
      stage.classList.add('focus-mode');
      document.body.classList.add('game-focused');
    }
    updateFullscreenButton();
    canvas.focus();
  }

  function toggleGuide(force) {
    var open = typeof force === 'boolean' ? force : !guide.classList.contains('open');
    guide.classList.toggle('open', open);
    guide.setAttribute('aria-hidden', String(!open));
    helpButton.setAttribute('aria-expanded', String(open));
    if (!open) canvas.focus();
  }

  function sendGameKey(key) {
    var code = key === 'home' ? 'Home' : key === '=' ? 'Equal' : 'Minus';
    var value = key === 'home' ? 'Home' : key;
    canvas.focus();
    canvas.dispatchEvent(new KeyboardEvent('keydown', { key: value, code: code, bubbles: true }));
    canvas.dispatchEvent(new KeyboardEvent('keyup', { key: value, code: code, bubbles: true }));
  }

  fullscreenButton.addEventListener('click', toggleFullscreen);
  helpButton.addEventListener('click', function () { toggleGuide(); });
  helpClose.addEventListener('click', function () { toggleGuide(false); });
  document.querySelectorAll('[data-game-key]').forEach(function (button) {
    button.addEventListener('click', function () { sendGameKey(button.dataset.gameKey); });
  });
  document.addEventListener('fullscreenchange', function () {
    if (!fullscreenElement()) leaveFocusMode();
    updateFullscreenButton();
  });
  document.addEventListener('webkitfullscreenchange', updateFullscreenButton);
  canvas.addEventListener('touchmove', function (event) { event.preventDefault(); }, { passive: false });
  window.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && guide.classList.contains('open')) toggleGuide(false);
  });
  updateFullscreenButton();
})();
