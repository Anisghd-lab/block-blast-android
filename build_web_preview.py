import json

# Read levels
with open('/root/block_blast_android/assets/levels/levels.json', 'r', encoding='utf-8') as f:
    levels_data = json.load(f)

levels_json_str = json.dumps(levels_data['levels'], ensure_ascii=False)

html_template = """<!DOCTYPE html>
<html lang="fr" class="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Block Blast Color - Jouable Android & Web</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Rubik:wght@500;600;700;800;900&family=Space+Grotesk:wght@600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
    }
    body {
      background-color: #0c0d1d;
      font-family: 'Rubik', sans-serif;
      user-select: none;
      -webkit-user-select: none;
      overflow: hidden;
      touch-action: none;
      overscroll-behavior: none;
    }
    .font-num {
      font-family: 'Space Grotesk', sans-serif;
    }
    .grid-board {
      display: grid;
      grid-template-columns: repeat(8, 1fr);
      gap: 4px;
      padding: 8px;
      background: #17182b;
      border-radius: 18px;
      border: 1.5px solid rgba(255, 255, 255, 0.09);
      box-shadow: 0 14px 35px rgba(0, 0, 0, 0.6);
      touch-action: none;
    }
    .cell {
      aspect-ratio: 1;
      border-radius: 6px;
      background: #111224;
      border: 1px solid #1f213b;
      transition: background-color 0.1s, transform 0.15s;
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .cell.filled {
      border: 1px solid rgba(255, 255, 255, 0.4);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.35);
    }
    /* Joyaux / Gemmes (2) */
    .cell.jewel {
      background: radial-gradient(circle at 35% 35%, #80ffff, #00c6ff 50%, #0072ff);
      border: 1.5px solid #ffffff;
      box-shadow: 0 0 14px rgba(0, 242, 254, 0.7), inset 0 0 6px rgba(255, 255, 255, 0.9);
      animation: jewelGlow 2.5s infinite ease-in-out;
    }
    @keyframes jewelGlow {
      0%, 100% { box-shadow: 0 0 10px rgba(0, 242, 254, 0.5), inset 0 0 6px rgba(255, 255, 255, 0.8); }
      50% { box-shadow: 0 0 18px rgba(0, 242, 254, 0.95), inset 0 0 10px rgba(255, 255, 255, 1); }
    }
    .jewel-icon {
      filter: drop-shadow(0 2px 4px rgba(0,0,0,0.5));
      animation: jewelPulse 2s infinite ease-in-out;
    }
    @keyframes jewelPulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.15); }
    }
    /* Roches / Obstacles (-1) */
    .cell.rock {
      background: linear-gradient(145deg, #3a3e52, #202334);
      border: 1.5px solid #5a5f78;
      box-shadow: inset 1px 1px 3px rgba(255, 255, 255, 0.15), inset -2px -2px 4px rgba(0, 0, 0, 0.8);
    }
    .rock-icon {
      opacity: 0.9;
      filter: drop-shadow(0 2px 4px rgba(0,0,0,0.7));
    }
    /* Prévisualisation Fantôme */
    .cell.ghost-valid {
      background: rgba(0, 242, 254, 0.45) !important;
      border: 1.5px solid #00f2fe !important;
    }
    .cell.ghost-invalid {
      background: rgba(255, 8, 68, 0.45) !important;
      border: 1.5px solid #ff0844 !important;
    }
    /* Animation Blast */
    .cell.blast {
      background: #ffffff !important;
      box-shadow: 0 0 20px #ffffff, 0 0 45px #00f2fe !important;
      transform: scale(1.12);
      z-index: 10;
    }
    .cell.blast-jewel {
      background: #ffffff !important;
      box-shadow: 0 0 25px #00f2fe, 0 0 50px #ff00ff !important;
      transform: scale(1.2);
      z-index: 12;
    }
    .cell.blast-rock {
      background: #8e95a5 !important;
      box-shadow: 0 0 20px #64748b !important;
      transform: scale(1.1);
      z-index: 10;
    }
    /* Couleurs de blocs vifs */
    .color-1 { background: linear-gradient(135deg, #6ff6ff, #00f2fe, #008f96); }
    .color-2 { background: linear-gradient(135deg, #ff708d, #ff0844, #990024); }
    .color-3 { background: linear-gradient(135deg, #fff085, #fed929, #997f00); }
    .color-4 { background: linear-gradient(135deg, #7affc8, #00f5a0, #008f5d); }
    .color-5 { background: linear-gradient(135deg, #c4a1ff, #8b5cf6, #4c1d95); }
    .color-6 { background: linear-gradient(135deg, #ffa366, #ff6a00, #993f00); }
    .color-7 { background: linear-gradient(135deg, #8ad8ff, #38bdf8, #0369a1); }

    /* Particules */
    .particle {
      position: absolute;
      pointer-events: none;
      border-radius: 50%;
      animation: fly 0.6s cubic-bezier(0.1, 0.8, 0.3, 1) forwards;
    }
    @keyframes fly {
      0% { transform: translate(0, 0) scale(1); opacity: 1; }
      100% { transform: translate(var(--dx), var(--dy)) scale(0); opacity: 0; }
    }
    .btn-action {
      cursor: pointer;
      touch-action: manipulation;
    }
    .btn-action:active {
      transform: scale(0.93);
    }
    /* Masquer la scrollbar tout en permettant le scroll */
    .no-scrollbar::-webkit-scrollbar {
      display: none;
    }
    .no-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
  </style>
</head>
<body class="w-screen h-screen flex flex-col items-center justify-between p-3.5 max-w-md mx-auto">
  
  <!-- HUD Supérieur -->
  <header class="w-full flex flex-col items-center pt-1">
    <!-- Barre de boutons hauts -->
    <div class="w-full flex items-center justify-between px-1 mb-1.5">
      <!-- Bouton Pause -->
      <button id="btnPause" type="button" class="btn-action w-10 h-10 rounded-full bg-[#1b1c31] border border-white/15 flex items-center justify-center text-white shadow-lg">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
      </button>

      <!-- Switcher Mode : Classique / Aventure -->
      <div class="flex items-center bg-[#15162a] p-1 rounded-full border border-white/10 shadow-inner">
        <button id="tabModeLevels" type="button" class="btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-md">
          🗺️ Niveaux (50)
        </button>
        <button id="tabModeClassic" type="button" class="btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all text-gray-400 hover:text-white">
          ⚡ Classique
        </button>
      </div>

      <!-- Bouton Son -->
      <button id="btnSound" type="button" class="btn-action w-10 h-10 rounded-full bg-[#1b1c31] border border-white/15 flex items-center justify-center text-white shadow-lg">
        <span id="soundIcon" class="text-base">🔊</span>
      </button>
    </div>

    <!-- HUD Mode Aventure (Niveaux) -->
    <div id="hudLevels" class="w-full flex flex-col items-center">
      <!-- Titre Niveau & Bouton Choix de Niveau -->
      <div class="w-full flex items-center justify-between px-1">
        <button id="btnOpenLevelSelect" type="button" class="btn-action flex items-center gap-1.5 px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-400/30 text-cyan-300 text-xs font-bold">
          <span id="txtLevelBadge">Niveau 1</span>
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
        </button>
        <div id="txtLevelTitle" class="text-xs font-semibold text-gray-300 truncate max-w-[200px]">
          Apprentissage 1
        </div>
      </div>

      <!-- Cartes Objectif & Coups Restants -->
      <div class="w-full grid grid-cols-2 gap-2 mt-2">
        <!-- Objectif -->
        <div class="bg-[#17182b] border border-white/10 rounded-2xl p-2 flex items-center gap-2.5 shadow-md">
          <div id="goalIconBox" class="w-9 h-9 rounded-xl bg-cyan-500/20 border border-cyan-400/40 flex items-center justify-center text-xl shrink-0">
            🎯
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Objectif</span>
            <span id="txtGoalProgress" class="font-num text-sm font-extrabold text-white truncate">0 / 420</span>
          </div>
        </div>

        <!-- Coups Restants -->
        <div class="bg-[#17182b] border border-white/10 rounded-2xl p-2 flex items-center gap-2.5 shadow-md">
          <div id="movesIconBox" class="w-9 h-9 rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-xl shrink-0">
            👣
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Coups</span>
            <span id="txtMovesRemaining" class="font-num text-sm font-extrabold text-amber-300 truncate">Illimité</span>
          </div>
        </div>
      </div>
    </div>

    <!-- HUD Mode Classique -->
    <div id="hudClassic" class="w-full flex-col items-center hidden">
      <div class="flex items-center space-x-1.5 px-3 py-1 rounded-full bg-[#1b1c31] border border-amber-400/30 text-amber-400 font-num text-xs font-bold shadow-md">
        <span>👑 RECORD :</span>
        <span id="txtHighScore">0</span>
      </div>
      <div id="txtScoreClassic" class="text-4xl font-black text-white mt-1 tracking-tight drop-shadow-[0_4px_12px_rgba(0,242,254,0.4)]">
        0
      </div>
    </div>

    <!-- Combo Banner -->
    <div id="comboBanner" class="h-6 mt-1 flex items-center justify-center transition-all duration-200 opacity-0 transform scale-90">
      <div class="px-3.5 py-0.5 rounded-full bg-gradient-to-r from-[#ff0844] via-[#ff6a00] to-[#fed929] text-white text-[11px] font-black shadow-lg shadow-orange-500/40">
        🔥 COMBO x2! MEGA BLAST!
      </div>
    </div>
  </header>

  <!-- Grille 8x8 Centrale -->
  <main class="w-full max-w-[360px] aspect-square relative my-auto">
    <div id="board" class="grid-board w-full h-full"></div>
    <div id="particleContainer" class="absolute inset-0 pointer-events-none overflow-hidden"></div>
  </main>

  <!-- Tiroir de 3 Pièces Inférieur -->
  <footer class="w-full max-w-[380px] pb-2">
    <div class="w-full h-34 bg-[#17182b]/90 border border-white/10 rounded-2xl flex items-center justify-around px-1 py-1" id="dock">
      <!-- 3 Emplacements de formes -->
      <div class="w-28 h-32 flex flex-col items-center justify-center" id="slot-0"></div>
      <div class="w-28 h-32 flex flex-col items-center justify-center" id="slot-1"></div>
      <div class="w-28 h-32 flex flex-col items-center justify-center" id="slot-2"></div>
    </div>
  </footer>

  <!-- Élément flottant de glissement (Drag Ghost) -->
  <div id="dragGhost" class="fixed pointer-events-none z-50 hidden"></div>

  <!-- Modal Choix de Niveau (1 à 50) -->
  <div id="levelSelectModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex flex-col items-center justify-center p-4 z-50 hidden">
    <div class="w-full max-w-md max-h-[90vh] bg-[#111224] border-2 border-white/20 rounded-3xl p-5 flex flex-col shadow-2xl">
      <!-- En-tête modal -->
      <div class="flex items-center justify-between pb-3 border-b border-white/10">
        <div>
          <h2 class="text-xl font-black text-white">CHOIX DU NIVEAU</h2>
          <p class="text-xs text-gray-400 font-semibold">50 Niveaux Aventure Défi</p>
        </div>
        <button id="btnCloseLevelSelect" type="button" class="btn-action w-9 h-9 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20">
          ✕
        </button>
      </div>

      <!-- Onglets de sections (1-25 / 26-50) -->
      <div class="flex gap-2 my-3">
        <button id="tabPart1" type="button" class="btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-cyan-500 text-black">
          Partie 1 (1 - 25)
        </button>
        <button id="tabPart2" type="button" class="btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-[#1d1e30] text-gray-300">
          Partie 2 (26 - 50)
        </button>
      </div>

      <!-- Grille des niveaux (scrollable) -->
      <div id="levelCardsGrid" class="flex-1 overflow-y-auto no-scrollbar grid grid-cols-5 gap-2.5 p-1">
        <!-- Rempli dynamiquement en JS -->
      </div>
    </div>
  </div>

  <!-- Modal Victoire de Niveau -->
  <div id="victoryModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex items-center justify-center p-6 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-emerald-400 rounded-3xl p-6 text-center shadow-2xl shadow-emerald-500/30">
      <div class="text-5xl mb-2 animate-bounce">🎉</div>
      <h2 class="text-2xl font-black text-emerald-400 mb-1">VICTOIRE !</h2>
      <div id="txtVictoryLevelTitle" class="text-xs font-semibold text-gray-300 mb-4">Niveau Réussi</div>

      <!-- Étoiles gagnées -->
      <div id="victoryStars" class="flex justify-center gap-2 text-3xl mb-5">
        <span class="text-amber-400">★</span>
        <span class="text-amber-400">★</span>
        <span class="text-amber-400">★</span>
      </div>

      <div class="bg-[#181a30] rounded-2xl p-3.5 mb-5 border border-white/5">
        <div class="flex justify-between items-center text-xs font-bold text-gray-400 py-1">
          <span>Score Niveau</span>
          <span id="txtVictoryScore" class="font-num text-white text-sm font-black">0</span>
        </div>
        <div id="rowVictoryMoves" class="flex justify-between items-center text-xs font-bold text-gray-400 py-1 border-t border-white/5">
          <span>Coups restants</span>
          <span id="txtVictoryMoves" class="font-num text-amber-300 text-sm font-black">0</span>
        </div>
      </div>

      <button id="btnNextLevel" type="button" class="btn-action w-full py-3.5 bg-gradient-to-r from-emerald-400 to-cyan-400 text-[#002f20] font-black rounded-xl text-base mb-2.5 shadow-lg shadow-emerald-500/30">
        NIVEAU SUIVANT ▶
      </button>
      <div class="grid grid-cols-2 gap-2">
        <button id="btnReplayVictory" type="button" class="btn-action py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
          REJOUER ↺
        </button>
        <button id="btnLevelsFromVictory" type="button" class="btn-action py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
          NIVEAUX 🗺️
        </button>
      </div>
    </div>
  </div>

  <!-- Modal Défaite de Niveau -->
  <div id="defeatModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex items-center justify-center p-6 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-rose-500 rounded-3xl p-6 text-center shadow-2xl shadow-rose-500/30">
      <div class="text-4xl mb-2">💔</div>
      <h2 class="text-2xl font-black text-rose-500 mb-1">NIVEAU ÉCHOUÉ</h2>
      <div id="txtDefeatReason" class="text-xs text-gray-400 font-semibold mb-4">Plus de coups disponibles</div>

      <div class="bg-[#181a30] rounded-2xl p-4 mb-5 border border-white/5">
        <div class="text-[11px] font-bold text-gray-400 mb-1">Progression atteinte</div>
        <div id="txtDefeatProgress" class="font-num text-2xl font-black text-white">0 / 0</div>
      </div>

      <button id="btnRetryDefeat" type="button" class="btn-action w-full py-3.5 bg-gradient-to-r from-rose-500 to-orange-500 text-white font-black rounded-xl text-base mb-2.5 shadow-lg shadow-rose-500/30">
        RÉESSAYER ↺
      </button>
      <button id="btnLevelsFromDefeat" type="button" class="btn-action w-full py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
        CHOIX DU NIVEAU 🗺️
      </button>
    </div>
  </div>

  <!-- Modal Pause -->
  <div id="pauseModal" class="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-6 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-white/20 rounded-3xl p-6 text-center shadow-2xl">
      <h2 class="text-2xl font-black text-white mb-6">PARTIE EN PAUSE</h2>
      
      <div class="flex justify-center mb-6">
        <button id="btnToggleSoundPause" type="button" class="btn-action px-4 py-2.5 rounded-xl bg-[#1d1e30] border border-white/15 text-white font-bold text-sm flex items-center gap-2">
          <span id="soundIconPause">🔊</span> Son : <span id="soundStatusPause">ACTIF</span>
        </button>
      </div>

      <button id="btnResume" type="button" class="btn-action w-full py-3.5 bg-[#00f2fe] hover:bg-[#00dce6] text-[#00373a] font-black rounded-xl text-lg mb-3 shadow-lg shadow-cyan-500/30 transition">
        REPRENDRE
      </button>
      <button id="btnRestartFromPause" type="button" class="btn-action w-full py-3 bg-[#1d1e30] hover:bg-[#252742] text-white font-bold rounded-xl text-sm border border-white/10 transition">
        RECOMMENCER
      </button>
    </div>
  </div>

  <!-- Modal Game Over Classique -->
  <div id="gameOverModal" class="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-6 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-[#00f2fe] rounded-3xl p-6 text-center shadow-2xl shadow-cyan-500/30">
      <div class="text-4xl mb-2">🏆</div>
      <h2 class="text-2xl font-black text-white mb-4">PARTIE TERMINÉE</h2>
      <div class="bg-[#181a30] rounded-2xl p-4 mb-6">
        <div class="text-xs font-bold text-gray-400 font-num">SCORE</div>
        <div id="modalScore" class="text-4xl font-black text-white my-1">0</div>
        <div class="text-xs font-bold text-amber-400 font-num">RECORD : <span id="modalBest">0</span></div>
      </div>
      <button id="btnRestart" type="button" class="btn-action w-full py-3.5 bg-[#00f2fe] hover:bg-[#00dce6] text-[#00373a] font-black rounded-xl text-lg shadow-lg shadow-cyan-500/30 transition">
        REJOUER
      </button>
    </div>
  </div>

  <script>
    // --- DONNÉES DES 50 NIVEAUX INTÉGRÉES ---
    const ALL_LEVELS = """ + levels_json_str + """;

    // --- DICTIONNAIRE DES FORMES DU JEU ---
    const SHAPE_DICTIONARY = {
      "1x1": [[1]],
      "1x2_h": [[1, 1]],
      "1x2_v": [[1], [1]],
      "1x3_h": [[1, 1, 1]],
      "1x3_v": [[1], [1], [1]],
      "1x4_h": [[1, 1, 1, 1]],
      "1x4_v": [[1], [1], [1], [1]],
      "1x5_h": [[1, 1, 1, 1, 1]],
      "1x5_v": [[1], [1], [1], [1], [1]],
      "2x2": [[1, 1], [1, 1]],
      "3x3": [[1, 1, 1], [1, 1, 1], [1, 1, 1]],
      "L_normal": [[1, 0], [1, 0], [1, 1]],
      "L_inv": [[0, 1], [0, 1], [1, 1]],
      "L_giant": [[1, 0, 0], [1, 0, 0], [1, 1, 1]],
      "S_shape": [[0, 1, 1], [1, 1, 0]],
      "Z_shape": [[1, 1, 0], [0, 1, 1]],
      "T_shape": [[1, 1, 1], [0, 1, 0]],
      "U_shape": [[1, 0, 1], [1, 1, 1]],
      "plus_5": [[0, 1, 0], [1, 1, 1], [0, 1, 0]]
    };

    const CLASSIC_SHAPES = [
      [[1]], // 1x1
      [[1, 1]], [[1], [1]], // 1x2, 2x1
      [[1, 1, 1]], [[1], [1], [1]], // 1x3, 3x1
      [[1, 1, 1, 1]], [[1], [1], [1], [1]], // 1x4, 4x1
      [[1, 1, 1, 1, 1]], [[1], [1], [1], [1], [1]], // 1x5, 5x1
      [[1, 1], [1, 1]], // Carré 2x2
      [[1, 1, 1], [1, 1, 1], [1, 1, 1]], // Carré géant 3x3
      [[1, 1], [1, 0]], // Coin 3 blocs
      [[1, 0], [1, 0], [1, 1]], // Grand L
      [[0, 1], [0, 1], [1, 1]], // Grand J
      [[1, 1, 1], [0, 1, 0]], // T
      [[1, 1, 0], [0, 1, 1]], // Z
      [[0, 1, 1], [1, 1, 0]], // S
      [[1, 1, 1], [1, 0, 0], [1, 0, 0]] // Grand coin 3x3
    ];

    // --- AUDIO SYNTHESIS ---
    let audioCtx = null;
    let soundEnabled = true;

    function initAudio() {
      if (!audioCtx) {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      }
      if (audioCtx.state === 'suspended') {
        audioCtx.resume();
      }
    }

    const comboNotes = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 659.25];

    function playNote(freq) {
      if (!soundEnabled) return;
      initAudio();
      try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.28, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.35);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.35);
      } catch(e) {}
    }

    function playClick() {
      if (!soundEnabled) return;
      initAudio();
      try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(580, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.18, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.08);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.08);
      } catch(e) {}
    }

    function playRotate() {
      if (!soundEnabled) return;
      initAudio();
      try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(420, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(750, audioCtx.currentTime + 0.12);
        gain.gain.setValueAtTime(0.22, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.12);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.12);
      } catch(e) {}
    }

    function playJewelSound() {
      if (!soundEnabled) return;
      initAudio();
      try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(1760, audioCtx.currentTime + 0.25);
        gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.3);
      } catch(e) {}
    }

    function playVictorySound() {
      if (!soundEnabled) return;
      [523.25, 659.25, 783.99, 1046.50].forEach((freq, i) => {
        setTimeout(() => playNote(freq), i * 110);
      });
    }

    // --- ROTATION 90° ET MIROIR ---
    function rotateMatrix(matrix) {
      const rows = matrix.length;
      const cols = matrix[0].length;
      const rotated = Array(cols).fill(null).map(() => Array(rows).fill(0));
      for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
          rotated[c][rows - 1 - r] = matrix[r][c];
        }
      }
      return rotated;
    }

    // --- ÉTAT DU JEU ---
    const SIZE = 8;
    let gameMode = 'levels'; // 'levels' ou 'classic'
    let currentLevelIndex = 0; // 0 à 49 (Niveau 1 à 50)
    
    // Grille : 0: vide, 1-7: bloc de couleur, 2: joyau (initial), -1: roche
    let grid = Array(SIZE).fill(null).map(() => Array(SIZE).fill(0));
    
    // Progression & Stockage
    let levelProgress = {
      unlockedLevel: 1,
      completed: {}
    };
    try {
      const saved = localStorage.getItem('block_blast_level_progress');
      if (saved) levelProgress = JSON.parse(saved);
      if (!levelProgress.unlockedLevel) levelProgress.unlockedLevel = 1;
      if (!levelProgress.completed) levelProgress.completed = {};
    } catch(e) {}

    let classicScore = 0;
    let classicHighScore = parseInt(localStorage.getItem('block_blast_best') || '0');
    
    // Statistiques du niveau en cours
    let levelScore = 0;
    let levelLinesCleared = 0;
    let levelJewelsCollected = 0;
    let movesRemaining = 0;
    
    let comboStreak = 0;
    let availablePieces = [null, null, null];
    let isGameOver = false;
    let isPaused = false;

    // DOM Elements
    const boardEl = document.getElementById('board');
    const dragGhost = document.getElementById('dragGhost');
    const particleContainer = document.getElementById('particleContainer');
    const comboBanner = document.getElementById('comboBanner');
    
    const hudLevels = document.getElementById('hudLevels');
    const hudClassic = document.getElementById('hudClassic');
    const tabModeLevels = document.getElementById('tabModeLevels');
    const tabModeClassic = document.getElementById('tabModeClassic');
    
    const txtLevelBadge = document.getElementById('txtLevelBadge');
    const txtLevelTitle = document.getElementById('txtLevelTitle');
    const goalIconBox = document.getElementById('goalIconBox');
    const txtGoalProgress = document.getElementById('txtGoalProgress');
    const txtMovesRemaining = document.getElementById('txtMovesRemaining');
    const movesIconBox = document.getElementById('movesIconBox');
    
    const txtScoreClassic = document.getElementById('txtScoreClassic');
    const txtHighScore = document.getElementById('txtHighScore');
    txtHighScore.textContent = classicHighScore;

    // Initialisation du DOM de la grille 8x8
    for (let r = 0; r < SIZE; r++) {
      for (let c = 0; c < SIZE; c++) {
        const cell = document.createElement('div');
        cell.className = 'cell';
        cell.id = `cell-${r}-${c}`;
        boardEl.appendChild(cell);
      }
    }

    // --- RENDU DE LA GRILLE ---
    function renderBoard() {
      for (let r = 0; r < SIZE; r++) {
        for (let c = 0; c < SIZE; c++) {
          const cell = document.getElementById(`cell-${r}-${c}`);
          cell.className = 'cell';
          cell.innerHTML = '';
          const val = grid[r][c];

          if (val === 2) {
            // Joyau
            cell.classList.add('jewel');
            cell.innerHTML = '<div class="jewel-icon text-sm">💎</div>';
          } else if (val === -1) {
            // Roche
            cell.classList.add('rock');
            cell.innerHTML = '<div class="rock-icon text-sm">🪨</div>';
          } else if (val > 0) {
            // Bloc normal ou coloré
            const colorClass = val === 1 ? 'color-1' : `color-${val}`;
            cell.classList.add('filled', colorClass);
          }
        }
      }
    }

    // --- CHARGEMENT D'UN NIVEAU ---
    function loadLevel(levelIndex) {
      if (levelIndex < 0) levelIndex = 0;
      if (levelIndex >= ALL_LEVELS.length) levelIndex = ALL_LEVELS.length - 1;
      currentLevelIndex = levelIndex;
      const level = ALL_LEVELS[levelIndex];

      // Clone de la grille initiale
      grid = level.initial_grid.map(row => [...row]);

      // Réinitialisation des stats du niveau
      levelScore = 0;
      levelLinesCleared = 0;
      levelJewelsCollected = 0;
      comboStreak = 0;
      isGameOver = false;
      isPaused = false;
      movesRemaining = level.move_limit !== null ? level.move_limit : null;

      // Fermeture des modals
      document.getElementById('victoryModal').classList.add('hidden');
      document.getElementById('defeatModal').classList.add('hidden');
      document.getElementById('levelSelectModal').classList.add('hidden');
      document.getElementById('pauseModal').classList.add('hidden');

      updateLevelHUD();
      renderBoard();
      spawnTrio();
    }

    function updateLevelHUD() {
      const level = ALL_LEVELS[currentLevelIndex];
      txtLevelBadge.textContent = `Niveau ${level.level_id}`;
      txtLevelTitle.textContent = level.title;

      // Objectif
      if (level.goal === 'clear_jewels') {
        goalIconBox.textContent = '💎';
        txtGoalProgress.textContent = `${levelJewelsCollected} / ${level.target_value}`;
      } else if (level.goal === 'clear_lines') {
        goalIconBox.textContent = '📏';
        txtGoalProgress.textContent = `${levelLinesCleared} / ${level.target_value} Lig.`;
      } else {
        // Score
        goalIconBox.textContent = '🎯';
        txtGoalProgress.textContent = `${levelScore} / ${level.target_value} Pts`;
      }

      // Coups restants
      if (movesRemaining !== null) {
        txtMovesRemaining.textContent = `${movesRemaining}`;
        if (movesRemaining <= 3) {
          movesIconBox.className = 'w-9 h-9 rounded-xl bg-rose-500/20 border border-rose-400/40 flex items-center justify-center text-xl shrink-0 animate-pulse';
          txtMovesRemaining.className = 'font-num text-sm font-extrabold text-rose-400 truncate';
        } else {
          movesIconBox.className = 'w-9 h-9 rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-xl shrink-0';
          txtMovesRemaining.className = 'font-num text-sm font-extrabold text-amber-300 truncate';
        }
      } else {
        txtMovesRemaining.textContent = 'Illimité';
        movesIconBox.className = 'w-9 h-9 rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-xl shrink-0';
        txtMovesRemaining.className = 'font-num text-sm font-extrabold text-amber-300 truncate';
      }
    }

    // --- GÉNÉRATION DES PIÈCES (DOCK) ---
    function spawnTrio() {
      const level = ALL_LEVELS[currentLevelIndex];
      const allowedKeys = (gameMode === 'levels' && level && level.allowed_shapes && level.allowed_shapes.length > 0)
        ? level.allowed_shapes
        : null;

      for (let i = 0; i < 3; i++) {
        let matrix;
        if (allowedKeys) {
          const key = allowedKeys[Math.floor(Math.random() * allowedKeys.length)];
          matrix = SHAPE_DICTIONARY[key] || CLASSIC_SHAPES[0];
        } else {
          const shapeIdx = Math.floor(Math.random() * CLASSIC_SHAPES.length);
          matrix = CLASSIC_SHAPES[shapeIdx];
        }
        const colorIdx = (Math.floor(Math.random() * 7)) + 1;
        availablePieces[i] = {
          matrix: matrix.map(r => [...r]),
          color: colorIdx
        };
      }
      renderDock();
      checkGameOver();
    }

    function rotateSlotPiece(slotIndex) {
      if (isGameOver || isPaused) return;
      const piece = availablePieces[slotIndex];
      if (!piece) return;

      playRotate();
      if (navigator.vibrate) navigator.vibrate(25);

      piece.matrix = rotateMatrix(piece.matrix);
      renderDock();
      checkGameOver();
    }

    function renderDock() {
      for (let i = 0; i < 3; i++) {
        const slot = document.getElementById(`slot-${i}`);
        slot.innerHTML = '';
        const piece = availablePieces[i];
        if (!piece) continue;

        const pieceEl = createPieceElement(piece, 18);
        pieceEl.dataset.slot = i;
        attachDragHandlers(pieceEl, i);
        slot.appendChild(pieceEl);
      }
    }

    function createPieceElement(piece, cellSize) {
      const container = document.createElement('div');
      container.className = 'flex flex-col items-center justify-center cursor-grab active:cursor-grabbing p-1 rounded-lg';
      for (let r = 0; r < piece.matrix.length; r++) {
        const row = document.createElement('div');
        row.className = 'flex';
        for (let c = 0; c < piece.matrix[r].length; c++) {
          const block = document.createElement('div');
          block.style.width = `${cellSize}px`;
          block.style.height = `${cellSize}px`;
          block.style.margin = '1.5px';
          block.style.borderRadius = '4px';
          if (piece.matrix[r][c] > 0) {
            block.className = `filled color-${piece.color}`;
          }
          row.appendChild(block);
        }
        container.appendChild(row);
      }
      return container;
    }

    // --- DRAG & DROP GÉOMÉTRIQUE SANS DÉCALAGE ---
    let activeDrag = null;

    function getBoardMetrics() {
      const firstCell = document.getElementById('cell-0-0').getBoundingClientRect();
      const secondCell = document.getElementById('cell-0-1').getBoundingClientRect();
      const secondRowCell = document.getElementById('cell-1-0').getBoundingClientRect();
      const stepX = secondCell.left - firstCell.left;
      const stepY = secondRowCell.top - firstCell.top;
      return {
        firstCell,
        cellW: firstCell.width,
        cellH: firstCell.height,
        stepX,
        stepY
      };
    }

    function attachDragHandlers(el, slotIndex) {
      el.style.touchAction = 'none';

      const handleStart = (clientX, clientY) => {
        if (isGameOver || isPaused) return;
        const piece = availablePieces[slotIndex];
        if (!piece) return;

        initAudio();

        activeDrag = {
          slotIndex: slotIndex,
          piece: piece,
          element: el,
          startX: clientX,
          startY: clientY,
          hasMoved: false
        };

        const metrics = getBoardMetrics();
        dragGhost.innerHTML = '';
        const ghostPiece = createPieceElement(activeDrag.piece, metrics.cellW);
        dragGhost.appendChild(ghostPiece);
      };

      el.addEventListener('touchstart', (e) => {
        if (e.touches.length > 1) return;
        e.preventDefault();
        const t = e.touches[0];
        handleStart(t.clientX, t.clientY);
      }, { passive: false });

      el.addEventListener('mousedown', (e) => {
        if (e.button !== 0) return;
        e.preventDefault();
        handleStart(e.clientX, e.clientY);
      });
    }

    function updateDragPosition(clientX, clientY) {
      if (!activeDrag) return;

      const metrics = getBoardMetrics();
      const piece = activeDrag.piece;
      const rows = piece.matrix.length;
      const cols = piece.matrix[0].length;

      const pieceWidth = cols * metrics.cellW + (cols - 1) * 4;
      const pieceHeight = rows * metrics.cellH + (rows - 1) * 4;

      // Décalage vertical de 70px au-dessus du doigt pour une visibilité totale
      const visualCenterX = clientX;
      const visualCenterY = clientY - 70;

      const pieceLeft = visualCenterX - pieceWidth / 2;
      const pieceTop = visualCenterY - pieceHeight / 2;

      dragGhost.style.left = `${pieceLeft}px`;
      dragGhost.style.top = `${pieceTop}px`;
      dragGhost.style.transform = 'none';

      const targetCol = Math.round((pieceLeft - metrics.firstCell.left) / metrics.stepX);
      const targetRow = Math.round((pieceTop - metrics.firstCell.top) / metrics.stepY);

      clearGhostPreview();

      if (targetRow >= 0 && targetRow + rows <= SIZE &&
          targetCol >= 0 && targetCol + cols <= SIZE) {
        const isValid = canPlace(piece.matrix, targetRow, targetCol);
        highlightGhost(piece.matrix, targetRow, targetCol, isValid);
        activeDrag.target = { r: targetRow, c: targetCol, isValid: isValid };
      } else {
        activeDrag.target = null;
      }
    }

    function clearGhostPreview() {
      document.querySelectorAll('.cell.ghost-valid, .cell.ghost-invalid').forEach(c => {
        c.classList.remove('ghost-valid', 'ghost-invalid');
      });
    }

    function highlightGhost(matrix, startR, startC, isValid) {
      const cls = isValid ? 'ghost-valid' : 'ghost-invalid';
      for (let r = 0; r < matrix.length; r++) {
        for (let c = 0; c < matrix[r].length; c++) {
          if (matrix[r][c] > 0) {
            const tr = startR + r;
            const tc = startC + c;
            if (tr < SIZE && tc < SIZE) {
              const cell = document.getElementById(`cell-${tr}-${tc}`);
              if (cell) cell.classList.add(cls);
            }
          }
        }
      }
    }

    function handleMove(clientX, clientY) {
      if (!activeDrag) return;
      const dx = clientX - activeDrag.startX;
      const dy = clientY - activeDrag.startY;

      if (!activeDrag.hasMoved && (Math.abs(dx) > 4 || Math.abs(dy) > 4)) {
        activeDrag.hasMoved = true;
        playClick();
        if (navigator.vibrate) navigator.vibrate(15);
        dragGhost.classList.remove('hidden');
        activeDrag.element.style.opacity = '0.2';
      }

      if (activeDrag.hasMoved) {
        updateDragPosition(clientX, clientY);
      }
    }

    function handleEnd() {
      if (!activeDrag) return;

      if (!activeDrag.hasMoved) {
        // Tap simple : rotation immédiate de 90° de la pièce
        rotateSlotPiece(activeDrag.slotIndex);
      } else {
        if (activeDrag.target && activeDrag.target.isValid) {
          placePiece(activeDrag.piece, activeDrag.target.r, activeDrag.target.c, activeDrag.slotIndex);
        } else {
          activeDrag.element.style.opacity = '1';
        }
      }

      clearGhostPreview();
      dragGhost.classList.add('hidden');
      activeDrag = null;
    }

    // Événements globaux tactiles et souris
    window.addEventListener('touchmove', (e) => {
      if (!activeDrag) return;
      e.preventDefault();
      const t = e.touches[0];
      handleMove(t.clientX, t.clientY);
    }, { passive: false });

    window.addEventListener('touchend', (e) => {
      if (!activeDrag) return;
      e.preventDefault();
      handleEnd();
    }, { passive: false });

    window.addEventListener('touchcancel', (e) => {
      if (!activeDrag) return;
      handleEnd();
    });

    window.addEventListener('mousemove', (e) => {
      if (!activeDrag) return;
      handleMove(e.clientX, e.clientY);
    });

    window.addEventListener('mouseup', (e) => {
      if (!activeDrag) return;
      handleEnd();
    });

    // --- MOTEUR DE JEU ---
    function canPlace(matrix, startR, startC) {
      if (startR < 0 || startC < 0) return false;
      if (startR + matrix.length > SIZE || startC + matrix[0].length > SIZE) return false;
      for (let r = 0; r < matrix.length; r++) {
        for (let c = 0; c < matrix[r].length; c++) {
          if (matrix[r][c] > 0) {
            // Une cellule est bloquée si elle n'est pas vide (bloc, roche -1 ou joyau 2)
            if (grid[startR + r][startC + c] !== 0) {
              return false;
            }
          }
        }
      }
      return true;
    }

    function placePiece(piece, startR, startC, slotIndex) {
      let blocksPlaced = 0;
      for (let r = 0; r < piece.matrix.length; r++) {
        for (let c = 0; c < piece.matrix[r].length; c++) {
          if (piece.matrix[r][c] > 0) {
            grid[startR + r][startC + c] = piece.color;
            blocksPlaced++;
          }
        }
      }

      availablePieces[slotIndex] = null;
      renderDock();
      renderBoard();

      const piecePoints = blocksPlaced * 10;
      if (gameMode === 'levels') {
        levelScore += piecePoints;
        if (movesRemaining !== null) {
          movesRemaining--;
        }
        updateLevelHUD();
      } else {
        classicScore += piecePoints;
        updateClassicScore();
      }

      if (navigator.vibrate) navigator.vibrate(30);

      checkLines();
    }

    function checkLines() {
      const fullRows = [];
      const fullCols = [];

      // Une ligne est pleine si aucune cellule n'est 0
      for (let r = 0; r < SIZE; r++) {
        if (grid[r].every(c => c !== 0)) fullRows.push(r);
      }
      for (let c = 0; c < SIZE; c++) {
        let isFull = true;
        for (let r = 0; r < SIZE; r++) {
          if (grid[r][c] === 0) { isFull = false; break; }
        }
        if (isFull) fullCols.push(c);
      }

      const totalLines = fullRows.length + fullCols.length;
      if (totalLines > 0) {
        comboStreak++;
        const noteIdx = Math.min(comboStreak - 1, comboNotes.length - 1);
        playNote(comboNotes[noteIdx]);

        if (navigator.vibrate) navigator.vibrate(totalLines >= 2 ? 100 : 50);

        showComboBanner(comboStreak);

        let jewelsCleared = 0;
        let rocksCleared = 0;

        // Effets d'explosion sur les lignes
        const blastCell = (r, c) => {
          const el = document.getElementById(`cell-${r}-${c}`);
          const val = grid[r][c];
          if (val === 2) {
            jewelsCleared++;
            el.classList.add('blast-jewel');
            createParticles(el, 'cyan');
            playJewelSound();
          } else if (val === -1) {
            rocksCleared++;
            el.classList.add('blast-rock');
            createParticles(el, 'rock');
          } else {
            el.classList.add('blast');
            createParticles(el, val);
          }
        };

        fullRows.forEach(r => {
          for (let c = 0; c < SIZE; c++) blastCell(r, c);
        });
        fullCols.forEach(c => {
          for (let r = 0; r < SIZE; r++) blastCell(r, c);
        });

        // Calcul des points
        let lineBase = totalLines === 1 ? 100 : (totalLines === 2 ? 300 : (totalLines === 3 ? 600 : 1000));
        let mult = 1.0 + (comboStreak - 1) * 0.5;
        let pointsWon = Math.round(lineBase * mult) + (jewelsCleared * 50) + (rocksCleared * 30);

        if (gameMode === 'levels') {
          levelScore += pointsWon;
          levelLinesCleared += totalLines;
          levelJewelsCollected += jewelsCleared;
          updateLevelHUD();
        } else {
          classicScore += pointsWon;
          updateClassicScore();
        }

        setTimeout(() => {
          fullRows.forEach(r => {
            for (let c = 0; c < SIZE; c++) grid[r][c] = 0;
          });
          fullCols.forEach(c => {
            for (let r = 0; r < SIZE; r++) grid[r][c] = 0;
          });
          renderBoard();
          afterMove();
        }, 190);
      } else {
        comboStreak = 0;
        hideComboBanner();
        afterMove();
      }
    }

    function createParticles(cellEl, typeOrColor) {
      const rect = cellEl.getBoundingClientRect();
      const boardRect = boardEl.getBoundingClientRect();
      const centerX = rect.left - boardRect.left + rect.width / 2;
      const centerY = rect.top - boardRect.top + rect.height / 2;

      for (let i = 0; i < 7; i++) {
        const p = document.createElement('div');
        if (typeOrColor === 'cyan') {
          p.className = 'particle bg-cyan-400 shadow-[0_0_8px_#00f2fe]';
        } else if (typeOrColor === 'rock') {
          p.className = 'particle bg-slate-400';
        } else {
          p.className = `particle color-${typeOrColor}`;
        }
        p.style.left = `${centerX}px`;
        p.style.top = `${centerY}px`;
        p.style.width = '7px';
        p.style.height = '7px';
        const angle = Math.random() * Math.PI * 2;
        const dist = 25 + Math.random() * 45;
        p.style.setProperty('--dx', `${Math.cos(angle) * dist}px`);
        p.style.setProperty('--dy', `${Math.sin(angle) * dist}px`);
        particleContainer.appendChild(p);
        setTimeout(() => p.remove(), 600);
      }
    }

    function showComboBanner(streak) {
      if (streak < 2) return;
      comboBanner.firstElementChild.textContent = streak === 2 ? '🔥 COMBO x2! NICE!' : (streak === 3 ? '⚡ COMBO x3! MEGA BLAST!' : `👑 COMBO x${streak}! ULTRA!`);
      comboBanner.classList.remove('opacity-0', 'scale-90');
      comboBanner.classList.add('opacity-100', 'scale-100');
    }

    function hideComboBanner() {
      comboBanner.classList.remove('opacity-100', 'scale-100');
      comboBanner.classList.add('opacity-0', 'scale-90');
    }

    function afterMove() {
      if (gameMode === 'levels') {
        const level = ALL_LEVELS[currentLevelIndex];
        
        // 1. Vérification de la victoire
        let victory = false;
        if (level.goal === 'clear_jewels' && levelJewelsCollected >= level.target_value) victory = true;
        if (level.goal === 'clear_lines' && levelLinesCleared >= level.target_value) victory = true;
        if (level.goal === 'score' && levelScore >= level.target_value) victory = true;

        if (victory) {
          triggerLevelVictory();
          return;
        }

        // 2. Vérification de la limite de coups
        if (movesRemaining !== null && movesRemaining <= 0) {
          triggerLevelDefeat("Limite de coups atteinte !");
          return;
        }
      }

      // 3. Recharge le tiroir si les 3 pièces ont été jouées
      if (availablePieces.every(p => p === null)) {
        spawnTrio();
      } else {
        checkGameOver();
      }
    }

    function checkGameOver() {
      let canMove = false;
      for (const piece of availablePieces) {
        if (!piece) continue;
        for (let r = 0; r < SIZE; r++) {
          for (let c = 0; c < SIZE; c++) {
            if (canPlace(piece.matrix, r, c)) {
              canMove = true;
              break;
            }
          }
          if (canMove) break;
        }
        if (canMove) break;
      }

      if (!canMove && availablePieces.some(p => p !== null)) {
        if (gameMode === 'levels') {
          triggerLevelDefeat("Aucun coup possible sur la grille !");
        } else {
          triggerClassicGameOver();
        }
      }
    }

    // --- VICTOIRE & DÉFAITE EN MODE NIVEAU ---
    function triggerLevelVictory() {
      isGameOver = true;
      playVictorySound();
      const level = ALL_LEVELS[currentLevelIndex];

      // Calcul des étoiles
      let stars = 1;
      if (level.move_limit !== null) {
        const ratio = movesRemaining / level.move_limit;
        if (ratio >= 0.35) stars = 3;
        else if (ratio >= 0.1) stars = 2;
        else stars = 1;
      } else {
        if (levelScore >= level.target_value * 1.4) stars = 3;
        else if (levelScore >= level.target_value * 1.15) stars = 2;
        else stars = 1;
      }

      // Sauvegarde de la progression
      if (!levelProgress.completed[level.level_id] || levelProgress.completed[level.level_id].stars < stars) {
        levelProgress.completed[level.level_id] = { stars, score: levelScore };
      }
      if (currentLevelIndex + 2 > levelProgress.unlockedLevel && levelProgress.unlockedLevel < ALL_LEVELS.length) {
        levelProgress.unlockedLevel = currentLevelIndex + 2;
      }
      localStorage.setItem('block_blast_level_progress', JSON.stringify(levelProgress));

      // Affichage modal
      document.getElementById('txtVictoryLevelTitle').textContent = `Niveau ${level.level_id} : ${level.title}`;
      document.getElementById('txtVictoryScore').textContent = levelScore;
      
      const rowMoves = document.getElementById('rowVictoryMoves');
      if (level.move_limit !== null) {
        rowMoves.classList.remove('hidden');
        document.getElementById('txtVictoryMoves').textContent = movesRemaining;
      } else {
        rowMoves.classList.add('hidden');
      }

      const starsEl = document.getElementById('victoryStars');
      starsEl.innerHTML = '';
      for (let s = 1; s <= 3; s++) {
        const starSpan = document.createElement('span');
        starSpan.textContent = '★';
        starSpan.className = s <= stars ? 'text-amber-400 animate-pulse' : 'text-gray-600';
        starsEl.appendChild(starSpan);
      }

      document.getElementById('victoryModal').classList.remove('hidden');
    }

    function triggerLevelDefeat(reason) {
      isGameOver = true;
      const level = ALL_LEVELS[currentLevelIndex];
      document.getElementById('txtDefeatReason').textContent = reason;

      let progressText = '';
      if (level.goal === 'clear_jewels') progressText = `Gemmes : ${levelJewelsCollected} / ${level.target_value}`;
      else if (level.goal === 'clear_lines') progressText = `Lignes : ${levelLinesCleared} / ${level.target_value}`;
      else progressText = `Score : ${levelScore} / ${level.target_value}`;

      document.getElementById('txtDefeatProgress').textContent = progressText;
      document.getElementById('defeatModal').classList.remove('hidden');
    }

    function triggerClassicGameOver() {
      isGameOver = true;
      document.getElementById('modalScore').textContent = classicScore;
      document.getElementById('modalBest').textContent = classicHighScore;
      document.getElementById('gameOverModal').classList.remove('hidden');
    }

    function updateClassicScore() {
      txtScoreClassic.textContent = classicScore;
      if (classicScore > classicHighScore) {
        classicHighScore = classicScore;
        txtHighScore.textContent = classicHighScore;
        localStorage.setItem('block_blast_best', classicHighScore);
      }
    }

    function restartCurrentGame() {
      document.getElementById('gameOverModal').classList.add('hidden');
      document.getElementById('pauseModal').classList.add('hidden');
      document.getElementById('victoryModal').classList.add('hidden');
      document.getElementById('defeatModal').classList.add('hidden');

      if (gameMode === 'levels') {
        loadLevel(currentLevelIndex);
      } else {
        grid = Array(SIZE).fill(null).map(() => Array(SIZE).fill(0));
        classicScore = 0;
        comboStreak = 0;
        isGameOver = false;
        isPaused = false;
        updateClassicScore();
        hideComboBanner();
        renderBoard();
        spawnTrio();
      }
    }

    // --- SÉLECTION DES NIVEAUX ---
    let currentPart = 1; // 1: Niveaux 1-25, 2: Niveaux 26-50

    function openLevelSelect() {
      isPaused = true;
      renderLevelGrid();
      document.getElementById('levelSelectModal').classList.remove('hidden');
    }

    function closeLevelSelect() {
      document.getElementById('levelSelectModal').classList.add('hidden');
      isPaused = false;
    }

    function renderLevelGrid() {
      const gridContainer = document.getElementById('levelCardsGrid');
      gridContainer.innerHTML = '';
      const startIdx = (currentPart - 1) * 25;
      const endIdx = startIdx + 25;

      for (let i = startIdx; i < endIdx && i < ALL_LEVELS.length; i++) {
        const lvl = ALL_LEVELS[i];
        const isUnlocked = lvl.level_id <= levelProgress.unlockedLevel;
        const comp = levelProgress.completed[lvl.level_id];
        const stars = comp ? comp.stars : 0;
        const isCurrent = i === currentLevelIndex;

        const card = document.createElement('button');
        card.type = 'button';
        card.className = `btn-action flex flex-col items-center justify-center p-2 rounded-2xl border transition-all ${
          isCurrent
            ? 'bg-cyan-500/25 border-cyan-400 shadow-md shadow-cyan-500/30'
            : isUnlocked
            ? 'bg-[#1b1c31] border-white/10 hover:border-white/30 text-white'
            : 'bg-[#131422] border-white/5 opacity-40 cursor-not-allowed text-gray-500'
        }`;

        // Badge niveau
        const numSpan = document.createElement('span');
        numSpan.className = 'font-black text-sm font-num';
        numSpan.textContent = isUnlocked ? lvl.level_id : '🔒';
        card.appendChild(numSpan);

        // Étoiles ou icône
        if (isUnlocked) {
          const starBox = document.createElement('div');
          starBox.className = 'flex text-[9px] mt-1';
          for (let s = 1; s <= 3; s++) {
            const star = document.createElement('span');
            star.textContent = '★';
            star.className = s <= stars ? 'text-amber-400' : 'text-gray-600';
            starBox.appendChild(star);
          }
          card.appendChild(starBox);

          // Clic pour lancer le niveau
          card.addEventListener('click', () => {
            closeLevelSelect();
            switchMode('levels');
            loadLevel(i);
          });
        }

        gridContainer.appendChild(card);
      }
    }

    function switchMode(mode) {
      gameMode = mode;
      if (mode === 'levels') {
        tabModeLevels.className = 'btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-md';
        tabModeClassic.className = 'btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all text-gray-400 hover:text-white';
        hudLevels.classList.remove('hidden');
        hudClassic.classList.add('hidden');
        loadLevel(currentLevelIndex);
      } else {
        tabModeClassic.className = 'btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all bg-gradient-to-r from-amber-500 to-orange-600 text-white shadow-md';
        tabModeLevels.className = 'btn-action px-3.5 py-1.5 rounded-full text-xs font-bold transition-all text-gray-400 hover:text-white';
        hudLevels.classList.add('hidden');
        hudClassic.classList.remove('hidden');
        restartCurrentGame();
      }
    }

    function toggleSound() {
      soundEnabled = !soundEnabled;
      const icon = soundEnabled ? '🔊' : '🔇';
      const status = soundEnabled ? 'ACTIF' : 'MUET';
      document.getElementById('soundIcon').textContent = icon;
      document.getElementById('soundIconPause').textContent = icon;
      document.getElementById('soundStatusPause').textContent = status;
      document.getElementById('btnSound').classList.toggle('opacity-50', !soundEnabled);
    }

    // Gestionnaires des boutons
    const attachButtonHandler = (id, handler) => {
      const el = document.getElementById(id);
      if (!el) return;
      el.addEventListener('pointerdown', (e) => {
        e.preventDefault();
        e.stopPropagation();
        handler(e);
      });
      el.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        handler(e);
      });
    };

    attachButtonHandler('tabModeLevels', () => switchMode('levels'));
    attachButtonHandler('tabModeClassic', () => switchMode('classic'));
    attachButtonHandler('btnOpenLevelSelect', () => openLevelSelect());
    attachButtonHandler('btnCloseLevelSelect', () => closeLevelSelect());

    attachButtonHandler('tabPart1', () => {
      currentPart = 1;
      document.getElementById('tabPart1').className = 'btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-cyan-500 text-black';
      document.getElementById('tabPart2').className = 'btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-[#1d1e30] text-gray-300';
      renderLevelGrid();
    });

    attachButtonHandler('tabPart2', () => {
      currentPart = 2;
      document.getElementById('tabPart2').className = 'btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-cyan-500 text-black';
      document.getElementById('tabPart1').className = 'btn-action flex-1 py-2 rounded-xl text-xs font-bold bg-[#1d1e30] text-gray-300';
      renderLevelGrid();
    });

    attachButtonHandler('btnPause', () => {
      if (isGameOver) return;
      isPaused = true;
      document.getElementById('pauseModal').classList.remove('hidden');
    });

    attachButtonHandler('btnResume', () => {
      isPaused = false;
      document.getElementById('pauseModal').classList.add('hidden');
    });

    attachButtonHandler('btnRestartFromPause', () => restartCurrentGame());
    attachButtonHandler('btnRestart', () => restartCurrentGame());
    attachButtonHandler('btnRetryDefeat', () => restartCurrentGame());
    attachButtonHandler('btnReplayVictory', () => restartCurrentGame());

    attachButtonHandler('btnNextLevel', () => {
      if (currentLevelIndex + 1 < ALL_LEVELS.length) {
        loadLevel(currentLevelIndex + 1);
      } else {
        openLevelSelect();
      }
    });

    attachButtonHandler('btnLevelsFromVictory', () => openLevelSelect());
    attachButtonHandler('btnLevelsFromDefeat', () => openLevelSelect());

    attachButtonHandler('btnSound', () => toggleSound());
    attachButtonHandler('btnToggleSoundPause', () => toggleSound());

    // Démarrage initial en Mode Niveaux au Niveau 1
    loadLevel(0);
  </script>
</body>
</html>
"""

with open('/root/block_blast_android/web_preview/index.html', 'w', encoding='utf-8') as f:
    f.write(html_template)

print("web_preview/index.html successfully generated!")
