import json

# Read levels
with open('/root/block_blast_android/assets/levels/levels.json', 'r', encoding='utf-8') as f:
    levels_data = json.load(f)

levels_json_str = json.dumps(levels_data['levels'], ensure_ascii=False)

html_template = """<!DOCTYPE html>
<html lang="fr" class="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <title>Block Blast Color - Responsive Mobile, Tablette & Desktop</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Rubik:wght@500;600;700;800;900&family=Space+Grotesk:wght@600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
    }
    html, body {
      width: 100%;
      height: 100%;
      min-height: 100%;
      margin: 0;
      padding: 0;
      background-color: #070814;
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

    /* Grille 8x8 Responsive Ultra-Fluide (s'adapte à la hauteur ET à la largeur de l'écran) */
    .grid-board {
      display: grid;
      grid-template-columns: repeat(8, 1fr);
      aspect-ratio: 1 / 1;
      width: min(88vw, calc(100dvh - 295px), 360px);
      height: min(88vw, calc(100dvh - 295px), 360px);
      max-width: 360px;
      max-height: 360px;
      gap: clamp(2px, 0.9vw, 4px);
      padding: clamp(5px, 1.8vw, 8px);
      background: #17182b;
      border-radius: clamp(12px, 3vw, 18px);
      border: 1.5px solid rgba(255, 255, 255, 0.09);
      box-shadow: 0 12px 35px rgba(0, 0, 0, 0.65);
      touch-action: none;
      position: relative;
      margin: auto;
      flex-shrink: 0;
    }

    /* Deck des blocs strictement fixe et inaltérable par la forme des blocs */
    .fixed-dock-container {
      height: 104px !important;
      min-height: 104px !important;
      max-height: 104px !important;
      flex-shrink: 0 !important;
      box-sizing: border-box !important;
      overflow: hidden !important;
    }
    .fixed-dock-slot {
      width: 33.333% !important;
      height: 100% !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      box-sizing: border-box !important;
      position: relative !important;
    }
    .piece-slot-box {
      width: 76px !important;
      height: 76px !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      position: relative !important;
      flex-shrink: 0 !important;
    }

    .cell {
      aspect-ratio: 1;
      border-radius: clamp(4px, 1.2vw, 6px);
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
    /* Balayage Arc-en-ciel Finisher */
    .cell.rainbow-sweep {
      background: var(--sweep-color, #ffffff) !important;
      box-shadow: 0 0 24px var(--sweep-color, #ffffff) !important;
      transform: scale(1.15);
      z-index: 20;
    }
    /* Couleurs de blocs vifs */
    .color-1 { background: linear-gradient(135deg, #6ff6ff, #00f2fe, #008f96); }
    .color-2 { background: linear-gradient(135deg, #ff708d, #ff0844, #990024); }
    .color-3 { background: linear-gradient(135deg, #fff085, #fed929, #997f00); }
    .color-4 { background: linear-gradient(135deg, #7affc8, #00f5a0, #008f5d); }
    .color-5 { background: linear-gradient(135deg, #c4a1ff, #8b5cf6, #4c1d95); }
    .color-6 { background: linear-gradient(135deg, #ffa366, #ff6a00, #993f00); }
    .color-7 { background: linear-gradient(135deg, #8ad8ff, #38bdf8, #0369a1); }

    /* Particules & Confettis */
    .particle {
      position: absolute;
      pointer-events: none;
      border-radius: 50%;
      animation: fly 0.65s cubic-bezier(0.1, 0.8, 0.3, 1) forwards;
    }
    @keyframes fly {
      0% { transform: translate(0, 0) scale(1); opacity: 1; }
      100% { transform: translate(var(--dx), var(--dy)) scale(0); opacity: 0; }
    }
    /* Missiles Finisher */
    .finisher-missile {
      position: absolute;
      width: 14px;
      height: 36px;
      border-radius: 8px;
      background: linear-gradient(to top, #ff0844, #ff6a00, #fed929);
      box-shadow: 0 0 18px #ff6a00, 0 0 30px #ff0844;
      pointer-events: none;
      z-index: 40;
      animation: missileFly 0.4s cubic-bezier(0.2, 0.8, 0.4, 1) forwards;
    }
    @keyframes missileFly {
      0% { transform: translateY(180px) scale(0.6); opacity: 1; }
      80% { opacity: 1; }
      100% { transform: translateY(var(--target-y)) scale(1.3); opacity: 0; }
    }
    /* Gem Explosion Finisher */
    .giant-gem-shockwave {
      position: absolute;
      inset: 0;
      margin: auto;
      width: 80px;
      height: 80px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(0, 242, 254, 0.9), transparent 70%);
      box-shadow: 0 0 45px #00f2fe;
      animation: shockwave 0.6s ease-out forwards;
      pointer-events: none;
      z-index: 30;
    }
    @keyframes shockwave {
      0% { transform: scale(0.2); opacity: 1; }
      100% { transform: scale(3.5); opacity: 0; }
    }

    .btn-action {
      cursor: pointer;
      touch-action: manipulation;
    }
    .btn-action:active {
      transform: scale(0.93);
    }
    .no-scrollbar::-webkit-scrollbar {
      display: none;
    }
    .no-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
  </style>
</head>
<body class="flex items-center justify-center min-h-[100dvh] bg-[#080915]">
  
  <!-- Conteneur Principal Responsive (Fluidité mobile & Frame élégant desktop) -->
  <div id="appContainer" class="w-full h-[100dvh] max-h-[100dvh] flex flex-col justify-between p-2.5 sm:p-4 max-w-md mx-auto md:max-w-[430px] md:h-[94dvh] md:max-h-[850px] md:border md:border-cyan-500/25 md:rounded-[36px] md:shadow-[0_0_60px_rgba(0,242,254,0.18)] md:bg-[#0c0d1d] relative overflow-hidden">

    <!-- HUD Supérieur (Flexible et compact) -->
    <header class="w-full flex-shrink-0 flex flex-col items-center pt-0.5">
      <!-- Barre de boutons hauts -->
      <div class="w-full flex items-center justify-between px-0.5 mb-1.5">
        <!-- Bouton Pause -->
        <button id="btnPause" type="button" class="btn-action w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-[#1b1c31] border border-white/15 flex items-center justify-center text-white shadow-lg">
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
        </button>

        <!-- Switcher Mode : Classique / Aventure -->
        <div class="flex items-center bg-[#15162a] p-1 rounded-full border border-white/10 shadow-inner">
          <button id="tabModeLevels" type="button" class="btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-md">
            🗺️ Niveaux (50)
          </button>
          <button id="tabModeClassic" type="button" class="btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all text-gray-400 hover:text-white">
            ⚡ Classique
          </button>
        </div>

        <!-- Bouton Son -->
        <button id="btnSound" type="button" class="btn-action w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-[#1b1c31] border border-white/15 flex items-center justify-center text-white shadow-lg">
          <span id="soundIcon" class="text-sm sm:text-base">🔊</span>
        </button>
      </div>

      <!-- HUD Mode Aventure (Niveaux) -->
      <div id="hudLevels" class="w-full flex flex-col items-center">
        <!-- Titre Niveau & Bouton Choix de Niveau -->
        <div class="w-full flex items-center justify-between px-0.5">
          <button id="btnOpenLevelSelect" type="button" class="btn-action flex items-center gap-1 px-2.5 sm:px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-400/30 text-cyan-300 text-[11px] sm:text-xs font-bold">
            <span id="txtLevelBadge">Niveau 1</span>
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
          </button>
          <div class="flex flex-col items-end">
            <span id="txtLevelWorld" class="text-[9px] sm:text-[10px] font-bold text-cyan-400 uppercase tracking-wider">Monde Initiation</span>
            <span id="txtLevelTitle" class="text-xs sm:text-sm font-semibold text-gray-300 truncate max-w-[180px] sm:max-w-[210px]">Apprentissage 1</span>
          </div>
        </div>

        <!-- Cartes Objectif & Coups Restants -->
        <div class="w-full grid grid-cols-2 gap-1.5 sm:gap-2 mt-1.5">
          <!-- Objectif -->
          <div class="bg-[#17182b] border border-white/10 rounded-xl sm:rounded-2xl p-1.5 sm:p-2 flex items-center gap-2 shadow-md min-h-[46px]">
            <div id="goalIconBox" class="w-8 h-8 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-cyan-500/20 border border-cyan-400/40 flex items-center justify-center text-lg sm:text-xl shrink-0">
              🎯
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-[9px] sm:text-[10px] font-bold text-gray-400 uppercase tracking-wider">Objectif</span>
              <span id="txtGoalProgress" class="font-num text-xs sm:text-sm font-extrabold text-white truncate">0 / 420</span>
            </div>
          </div>

          <!-- Coups Restants -->
          <div class="bg-[#17182b] border border-white/10 rounded-xl sm:rounded-2xl p-1.5 sm:p-2 flex items-center gap-2 shadow-md min-h-[46px]">
            <div id="movesIconBox" class="w-8 h-8 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-lg sm:text-xl shrink-0">
              👣
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-[9px] sm:text-[10px] font-bold text-gray-400 uppercase tracking-wider">Coups</span>
              <span id="txtMovesRemaining" class="font-num text-xs sm:text-sm font-extrabold text-amber-300 truncate">Illimité</span>
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
        <div id="txtScoreClassic" class="text-3xl sm:text-4xl font-black text-white mt-1 tracking-tight drop-shadow-[0_4px_12px_rgba(0,242,254,0.4)]">
          0
        </div>
      </div>

      <!-- Combo Banner -->
      <div id="comboBanner" class="h-5 sm:h-6 mt-1 flex items-center justify-center transition-all duration-200 opacity-0 transform scale-90">
        <div class="px-3 py-0.5 rounded-full bg-gradient-to-r from-[#ff0844] via-[#ff6a00] to-[#fed929] text-white text-[10px] sm:text-[11px] font-black shadow-lg shadow-orange-500/40">
          🔥 COMBO x2! MEGA BLAST!
        </div>
      </div>
    </header>

    <!-- Grille 8x8 Centrale Auto-Centrée & Responsive -->
    <main class="w-full flex items-center justify-center my-auto flex-1 min-h-0 relative">
      <div id="board" class="grid-board"></div>
      <div id="particleContainer" class="absolute inset-0 pointer-events-none overflow-hidden"></div>
    </main>

    <!-- Tiroir de 3 Pièces Inférieur Fixe (Dimensions constantes, ne sort jamais de l'écran) -->
    <footer class="w-full flex-shrink-0 pb-1 sm:pb-2">
      <div class="fixed-dock-container w-full bg-[#17182b]/95 border border-white/10 rounded-2xl flex items-center justify-around px-1 py-1 shadow-2xl" id="dock">
        <div class="dock-slot fixed-dock-slot" id="slot-0"></div>
        <div class="dock-slot fixed-dock-slot" id="slot-1"></div>
        <div class="dock-slot fixed-dock-slot" id="slot-2"></div>
      </div>
    </footer>

  </div>

  <!-- Élément flottant de glissement (Drag Ghost) -->
  <div id="dragGhost" class="fixed pointer-events-none z-50 hidden"></div>

  <!-- Modal Choix de Niveau Responsive (1 à 50 classé par Mondes) -->
  <div id="levelSelectModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex flex-col items-center justify-center p-3 sm:p-5 z-50 hidden">
    <div class="w-full max-w-sm sm:max-w-md max-h-[90dvh] bg-[#111224] border-2 border-white/20 rounded-3xl p-4 sm:p-5 flex flex-col shadow-2xl">
      <div class="flex items-center justify-between pb-2 sm:pb-3 border-b border-white/10">
        <div>
          <h2 class="text-lg sm:text-xl font-black text-white">CHOIX DU NIVEAU</h2>
          <p class="text-[11px] sm:text-xs text-gray-400 font-semibold">5 Mondes • 50 Paliers Stratégiques</p>
        </div>
        <button id="btnCloseLevelSelect" type="button" class="btn-action w-8 h-8 sm:w-9 sm:h-9 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20">
          ✕
        </button>
      </div>

      <div class="flex overflow-x-auto no-scrollbar gap-1.5 my-2.5 py-1">
        <button id="worldTab-0" type="button" class="world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-cyan-500 text-black">
          🌟 Initiation (1-10)
        </button>
        <button id="worldTab-1" type="button" class="world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-[#1d1e30] text-gray-300">
          💎 Pierres (11-20)
        </button>
        <button id="worldTab-2" type="button" class="world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-[#1d1e30] text-gray-300">
          🗿 Poids Lourd (21-30)
        </button>
        <button id="worldTab-3" type="button" class="world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-[#1d1e30] text-gray-300">
          ⚡ Combos (31-40)
        </button>
        <button id="worldTab-4" type="button" class="world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-[#1d1e30] text-gray-300">
          👑 Master (41-50)
        </button>
      </div>

      <div id="levelCardsGrid" class="flex-1 overflow-y-auto no-scrollbar grid grid-cols-5 gap-2 sm:gap-2.5 p-1">
      </div>
    </div>
  </div>

  <!-- Modal Victoire Responsive -->
  <div id="victoryModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex items-center justify-center p-4 z-50 hidden">
    <div class="w-full max-w-xs sm:max-w-sm max-h-[92dvh] overflow-y-auto no-scrollbar bg-[#111224] border-2 border-emerald-400 rounded-3xl p-5 sm:p-6 text-center shadow-2xl shadow-emerald-500/30">
      
      <div id="txtVictoryBanner" class="text-xl sm:text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-emerald-300 via-yellow-200 to-amber-400 mb-0.5 animate-pulse">
        ÉCLATANT !
      </div>
      <div id="txtVictoryLevelTitle" class="text-xs font-semibold text-gray-300 mb-3">Niveau Réussi</div>

      <div id="victoryStars" class="flex justify-center gap-2 text-3xl sm:text-4xl mb-3 sm:mb-4">
        <span id="vStar-1" class="text-gray-600 transition-all duration-300">★</span>
        <span id="vStar-2" class="text-gray-600 transition-all duration-300">★</span>
        <span id="vStar-3" class="text-gray-600 transition-all duration-300">★</span>
      </div>

      <div class="bg-[#181a30] rounded-2xl p-2.5 sm:p-3 mb-3 border border-white/10 text-left space-y-1 text-[11px] sm:text-xs">
        <div class="flex justify-between items-center text-gray-300">
          <span>⭐ 1 : Objectif complété</span>
          <span class="text-emerald-400 font-bold">✓ Acquis</span>
        </div>
        <div id="rowStar2" class="flex justify-between items-center text-gray-300">
          <span>⭐ 2 : Coups restants (<span id="reqMovesStar2">≥ 5</span>)</span>
          <span id="statusStar2" class="font-bold text-amber-400">✓ Validé</span>
        </div>
        <div id="rowStar3" class="flex justify-between items-center text-gray-300">
          <span>⭐ 3 : Score élevé (<span id="reqScoreStar3">≥ 1200</span>)</span>
          <span id="statusStar3" class="font-bold text-amber-400">✓ Validé</span>
        </div>
      </div>

      <div class="bg-[#181a30] rounded-xl px-3 py-1.5 sm:py-2 mb-3 flex justify-between items-center border border-white/5">
        <span class="text-xs font-bold text-gray-400">Score Niveau</span>
        <span id="txtVictoryScore" class="font-num text-white text-sm sm:text-base font-black">0</span>
      </div>

      <button id="btnNextLevel" type="button" class="btn-action w-full py-3 sm:py-3.5 bg-gradient-to-r from-emerald-400 to-cyan-400 text-[#002f20] font-black rounded-xl text-sm sm:text-base mb-2 shadow-lg shadow-emerald-500/30">
        NIVEAU SUIVANT ▶
      </button>
      <div class="grid grid-cols-2 gap-2">
        <button id="btnReplayVictory" type="button" class="btn-action py-2 sm:py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
          REJOUER ↺
        </button>
        <button id="btnLevelsFromVictory" type="button" class="btn-action py-2 sm:py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
          NIVEAUX 🗺️
        </button>
      </div>
    </div>
  </div>

  <!-- Modal Défaite Responsive -->
  <div id="defeatModal" class="fixed inset-0 bg-black/85 backdrop-blur-md flex items-center justify-center p-4 z-50 hidden">
    <div class="w-full max-w-xs sm:max-w-sm max-h-[92dvh] overflow-y-auto no-scrollbar bg-[#111224] border-2 border-rose-500 rounded-3xl p-5 sm:p-6 text-center shadow-2xl shadow-rose-500/30">
      <div class="text-3xl sm:text-4xl mb-2">💔</div>
      <h2 class="text-xl sm:text-2xl font-black text-rose-500 mb-1">NIVEAU ÉCHOUÉ</h2>
      <div id="txtDefeatReason" class="text-xs text-gray-400 font-semibold mb-3">Plus de coups disponibles</div>

      <div class="bg-[#181a30] rounded-2xl p-3 sm:p-4 mb-4 border border-white/5">
        <div class="text-[10px] sm:text-[11px] font-bold text-gray-400 mb-1">Progression atteinte</div>
        <div id="txtDefeatProgress" class="font-num text-xl sm:text-2xl font-black text-white">0 / 0</div>
      </div>

      <button id="btnRetryDefeat" type="button" class="btn-action w-full py-3 sm:py-3.5 bg-gradient-to-r from-rose-500 to-orange-500 text-white font-black rounded-xl text-sm sm:text-base mb-2 shadow-lg shadow-rose-500/30">
        RÉESSAYER ↺
      </button>
      <button id="btnLevelsFromDefeat" type="button" class="btn-action w-full py-2 sm:py-2.5 bg-[#1e2038] hover:bg-[#282a48] text-white font-bold rounded-xl text-xs border border-white/10">
        CHOIX DU NIVEAU 🗺️
      </button>
    </div>
  </div>

  <!-- Modal Pause Responsive -->
  <div id="pauseModal" class="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-4 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-white/20 rounded-3xl p-5 sm:p-6 text-center shadow-2xl">
      <h2 class="text-xl sm:text-2xl font-black text-white mb-5">PARTIE EN PAUSE</h2>
      <div class="flex justify-center mb-5">
        <button id="btnToggleSoundPause" type="button" class="btn-action px-3.5 py-2 rounded-xl bg-[#1d1e30] border border-white/15 text-white font-bold text-xs sm:text-sm flex items-center gap-2">
          <span id="soundIconPause">🔊</span> Son : <span id="soundStatusPause">ACTIF</span>
        </button>
      </div>
      <button id="btnResume" type="button" class="btn-action w-full py-3 bg-[#00f2fe] hover:bg-[#00dce6] text-[#00373a] font-black rounded-xl text-base mb-2.5 shadow-lg shadow-cyan-500/30 transition">
        REPRENDRE
      </button>
      <button id="btnRestartFromPause" type="button" class="btn-action w-full py-2.5 bg-[#1d1e30] hover:bg-[#252742] text-white font-bold rounded-xl text-xs sm:text-sm border border-white/10 transition">
        RECOMMENCER
      </button>
    </div>
  </div>

  <!-- Modal Game Over Classique Responsive -->
  <div id="gameOverModal" class="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-4 z-50 hidden">
    <div class="w-full max-w-xs bg-[#111224] border-2 border-[#00f2fe] rounded-3xl p-5 sm:p-6 text-center shadow-2xl shadow-cyan-500/30">
      <div class="text-3xl sm:text-4xl mb-2">🏆</div>
      <h2 class="text-xl sm:text-2xl font-black text-white mb-3">PARTIE TERMINÉE</h2>
      <div class="bg-[#181a30] rounded-2xl p-3 sm:p-4 mb-4">
        <div class="text-xs font-bold text-gray-400 font-num">SCORE</div>
        <div id="modalScore" class="text-3xl sm:text-4xl font-black text-white my-1">0</div>
        <div class="text-xs font-bold text-amber-400 font-num">RECORD : <span id="modalBest">0</span></div>
      </div>
      <button id="btnRestart" type="button" class="btn-action w-full py-3 bg-[#00f2fe] hover:bg-[#00dce6] text-[#00373a] font-black rounded-xl text-base shadow-lg shadow-cyan-500/30 transition">
        REJOUER
      </button>
    </div>
  </div>

  <script>
    // --- DONNÉES DES 50 NIVEAUX ---
    const ALL_LEVELS = """ + levels_json_str + """;

    // --- DICTIONNAIRE DES FORMES ---
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

    // --- MOTEUR AUDIO (Web Audio API) ---
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
        osc.frequency.setValueAtTime(987.77, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(1760, audioCtx.currentTime + 0.25);
        gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.3);
      } catch(e) {}
    }

    function playRockCrush() {
      if (!soundEnabled) return;
      initAudio();
      try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(120, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(40, audioCtx.currentTime + 0.25);
        gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.25);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.25);
      } catch(e) {}
    }

    function playStarRevealSound(starNum) {
      if (!soundEnabled) return;
      initAudio();
      const chords = {
        1: [523.25, 659.25],
        2: [659.25, 783.99, 987.77],
        3: [523.25, 659.25, 783.99, 1046.50, 1318.51]
      };
      const notes = chords[starNum] || [523.25];
      notes.forEach((f, idx) => {
        setTimeout(() => {
          try {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(f, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.24, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.45);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.45);
          } catch(e) {}
        }, idx * 65);
      });
    }

    function playMissileShowerSound() {
      if (!soundEnabled) return;
      initAudio();
      for (let i = 0; i < 4; i++) {
        setTimeout(() => {
          try {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(200, audioCtx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(850, audioCtx.currentTime + 0.18);
            gain.gain.setValueAtTime(0.18, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.18);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.18);

            setTimeout(() => {
              try {
                const bOsc = audioCtx.createOscillator();
                const bGain = audioCtx.createGain();
                bOsc.type = 'sine';
                bOsc.frequency.setValueAtTime(130, audioCtx.currentTime);
                bOsc.frequency.exponentialRampToValueAtTime(35, audioCtx.currentTime + 0.22);
                bGain.gain.setValueAtTime(0.3, audioCtx.currentTime);
                bGain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.22);
                bOsc.connect(bGain);
                bGain.connect(audioCtx.destination);
                bOsc.start();
                bOsc.stop(audioCtx.currentTime + 0.22);
              } catch(e) {}
            }, 160);
          } catch(e) {}
        }, i * 140);
      }
    }

    function playGemExplosionSound() {
      if (!soundEnabled) return;
      initAudio();
      const freqs = [880, 1108.73, 1318.51, 1760, 2093.00];
      freqs.forEach((f, idx) => {
        setTimeout(() => {
          try {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(f, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.55);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.55);
          } catch(e) {}
        }, idx * 60);
      });
    }

    function playRainbowSweepSound() {
      if (!soundEnabled) return;
      initAudio();
      const notes = [392.00, 440.00, 523.25, 587.33, 659.25, 783.99, 880.00, 1046.50];
      notes.forEach((f, i) => {
        setTimeout(() => {
          try {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(f, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.22, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.3);
          } catch(e) {}
        }, i * 50);
      });
    }

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

    // --- BASE DE DONNÉES LOCALE DU TÉLÉPHONE (LocalStorage + IndexedDB Miroir) ---
    const LocalGameDB = {
      KEYS: {
        STATE: 'block_blast_ongoing_state_v2',
        PROGRESS: 'block_blast_level_progress_v2',
        HIGH_SCORE: 'block_blast_classic_high_v2',
        SETTINGS: 'block_blast_settings_v2'
      },

      // Sauvegarder l'état complet en cours (grille, pièces, scores, etc.)
      saveCurrentState(state) {
        try {
          localStorage.setItem(this.KEYS.STATE, JSON.stringify({
            ...state,
            savedAt: Date.now()
          }));
          this.syncToIndexedDB('ongoing_state', state);
        } catch (e) {}
      },

      loadCurrentState() {
        try {
          const raw = localStorage.getItem(this.KEYS.STATE);
          if (!raw) return null;
          return JSON.parse(raw);
        } catch (e) {
          return null;
        }
      },

      clearCurrentState() {
        try {
          localStorage.removeItem(this.KEYS.STATE);
          this.deleteFromIndexedDB('ongoing_state');
        } catch (e) {}
      },

      saveLevelProgress(prog) {
        try {
          localStorage.setItem(this.KEYS.PROGRESS, JSON.stringify(prog));
          this.syncToIndexedDB('level_progress', prog);
        } catch (e) {}
      },

      loadLevelProgress() {
        try {
          const raw = localStorage.getItem(this.KEYS.PROGRESS) || localStorage.getItem('block_blast_level_progress');
          if (raw) {
            const parsed = JSON.parse(raw);
            if (!parsed.unlockedLevel) parsed.unlockedLevel = 1;
            if (!parsed.completed) parsed.completed = {};
            return parsed;
          }
        } catch (e) {}
        return { unlockedLevel: 1, completed: {} };
      },

      saveHighScore(score) {
        try {
          const current = this.loadHighScore();
          if (score > current) {
            localStorage.setItem(this.KEYS.HIGH_SCORE, score.toString());
            this.syncToIndexedDB('high_score', score);
          }
        } catch (e) {}
      },

      loadHighScore() {
        try {
          const raw = localStorage.getItem(this.KEYS.HIGH_SCORE) || localStorage.getItem('block_blast_best');
          return parseInt(raw || '0', 10);
        } catch (e) {
          return 0;
        }
      },

      saveSettings(settings) {
        try {
          const cur = this.loadSettings();
          const merged = { ...cur, ...settings };
          localStorage.setItem(this.KEYS.SETTINGS, JSON.stringify(merged));
          this.syncToIndexedDB('settings', merged);
        } catch (e) {}
      },

      loadSettings() {
        try {
          const raw = localStorage.getItem(this.KEYS.SETTINGS);
          if (raw) return JSON.parse(raw);
        } catch (e) {}
        return { soundEnabled: true };
      },

      // Persistance IndexedDB native sur le smartphone
      _db: null,
      initIndexedDB() {
        if (!window.indexedDB) return;
        try {
          const req = indexedDB.open('BlockBlastDeviceDB', 1);
          req.onupgradeneeded = (e) => {
            const db = e.target.result;
            if (!db.objectStoreNames.contains('game_records')) {
              db.createObjectStore('game_records', { keyPath: 'key' });
            }
          };
          req.onsuccess = (e) => {
            this._db = e.target.result;
          };
        } catch (e) {}
      },

      syncToIndexedDB(key, data) {
        if (!this._db) return;
        try {
          const tx = this._db.transaction('game_records', 'readwrite');
          tx.objectStore('game_records').put({ key, data, updatedAt: Date.now() });
        } catch (e) {}
      },

      deleteFromIndexedDB(key) {
        if (!this._db) return;
        try {
          const tx = this._db.transaction('game_records', 'readwrite');
          tx.objectStore('game_records').delete(key);
        } catch (e) {}
      }
    };
    LocalGameDB.initIndexedDB();

    // --- ÉTAT DU JEU ---
    const SIZE = 8;
    let gameMode = 'levels';
    let currentLevelIndex = 0;
    
    let grid = Array(SIZE).fill(null).map(() => Array(SIZE).fill(0));
    let levelProgress = LocalGameDB.loadLevelProgress();

    let classicScore = 0;
    let classicHighScore = LocalGameDB.loadHighScore();
    
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
    const txtLevelWorld = document.getElementById('txtLevelWorld');
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

    function renderBoard() {
      for (let r = 0; r < SIZE; r++) {
        for (let c = 0; c < SIZE; c++) {
          const cell = document.getElementById(`cell-${r}-${c}`);
          cell.className = 'cell';
          cell.innerHTML = '';
          const val = grid[r][c];

          if (val === 2) {
            cell.classList.add('jewel');
            cell.innerHTML = '<div class="jewel-icon text-xs sm:text-sm">💎</div>';
          } else if (val === -1) {
            cell.classList.add('rock');
            cell.innerHTML = '<div class="rock-icon text-xs sm:text-sm">🪨</div>';
          } else if (val > 0) {
            const colorClass = val === 1 ? 'color-1' : `color-${val}`;
            cell.classList.add('filled', colorClass);
          }
        }
      }
    }

    function persistCurrentGame() {
      if (isGameOver) return;
      LocalGameDB.saveCurrentState({
        gameMode,
        currentLevelIndex,
        grid,
        availablePieces,
        levelScore,
        levelLinesCleared,
        levelJewelsCollected,
        movesRemaining,
        classicScore,
        comboStreak,
        isGameOver: false
      });
    }

    function loadLevel(levelIndex, restoreData = null) {
      if (levelIndex < 0) levelIndex = 0;
      if (levelIndex >= ALL_LEVELS.length) levelIndex = ALL_LEVELS.length - 1;
      currentLevelIndex = levelIndex;
      const level = ALL_LEVELS[levelIndex];

      if (restoreData) {
        grid = restoreData.grid.map(row => [...row]);
        levelScore = restoreData.levelScore || 0;
        levelLinesCleared = restoreData.levelLinesCleared || 0;
        levelJewelsCollected = restoreData.levelJewelsCollected || 0;
        comboStreak = restoreData.comboStreak || 0;
        isGameOver = false;
        isPaused = false;
        movesRemaining = restoreData.movesRemaining !== undefined ? restoreData.movesRemaining : null;
        availablePieces = restoreData.availablePieces ? restoreData.availablePieces.map(p => p ? { matrix: p.matrix.map(r => [...r]), color: p.color } : null) : [null, null, null];
      } else {
        grid = level.initial_grid.map(row => [...row]);
        levelScore = 0;
        levelLinesCleared = 0;
        levelJewelsCollected = 0;
        comboStreak = 0;
        isGameOver = false;
        isPaused = false;
        movesRemaining = level.move_limit !== null ? level.move_limit : null;
      }

      document.getElementById('victoryModal').classList.add('hidden');
      document.getElementById('defeatModal').classList.add('hidden');
      document.getElementById('levelSelectModal').classList.add('hidden');
      document.getElementById('pauseModal').classList.add('hidden');

      updateLevelHUD();
      renderBoard();
      if (restoreData) {
        renderDock();
        checkGameOver();
      } else {
        spawnTrio();
        persistCurrentGame();
      }
    }

    function updateLevelHUD() {
      const level = ALL_LEVELS[currentLevelIndex];
      txtLevelBadge.textContent = `Niveau ${level.level_id}`;
      txtLevelWorld.textContent = `Monde ${level.world || 'Aventure'}`;
      txtLevelTitle.textContent = level.title;

      if (level.goal === 'clear_jewels') {
        goalIconBox.textContent = '💎';
        txtGoalProgress.textContent = `${levelJewelsCollected} / ${level.target_value}`;
      } else if (level.goal === 'clear_lines') {
        goalIconBox.textContent = '📏';
        txtGoalProgress.textContent = `${levelLinesCleared} / ${level.target_value} Lig.`;
      } else {
        goalIconBox.textContent = '🎯';
        txtGoalProgress.textContent = `${levelScore} / ${level.target_value} Pts`;
      }

      if (movesRemaining !== null) {
        txtMovesRemaining.textContent = `${movesRemaining}`;
        if (movesRemaining <= 3) {
          movesIconBox.className = 'w-8 h-8 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-rose-500/20 border border-rose-400/40 flex items-center justify-center text-lg sm:text-xl shrink-0 animate-pulse';
          txtMovesRemaining.className = 'font-num text-xs sm:text-sm font-extrabold text-rose-400 truncate';
        } else {
          movesIconBox.className = 'w-8 h-8 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-lg sm:text-xl shrink-0';
          txtMovesRemaining.className = 'font-num text-xs sm:text-sm font-extrabold text-amber-300 truncate';
        }
      } else {
        txtMovesRemaining.textContent = 'Illimité';
        movesIconBox.className = 'w-8 h-8 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center text-lg sm:text-xl shrink-0';
        txtMovesRemaining.className = 'font-num text-xs sm:text-sm font-extrabold text-amber-300 truncate';
      }
    }

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
      persistCurrentGame();
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
      persistCurrentGame();
    }

    // Rendu Fixe et Uniforme des pièces dans le dock (dimensions strictement constantes)
    function renderDock() {
      for (let i = 0; i < 3; i++) {
        const slot = document.getElementById(`slot-${i}`);
        if (!slot) continue;
        slot.innerHTML = '';
        const piece = availablePieces[i];

        const box = document.createElement('div');
        box.className = 'piece-slot-box';

        if (!piece) {
          const placeholder = document.createElement('div');
          placeholder.className = 'w-[72px] h-[72px] rounded-xl border border-white/5 bg-white/[0.015] flex items-center justify-center';
          box.appendChild(placeholder);
          slot.appendChild(box);
          continue;
        }

        const rows = piece.matrix.length;
        const cols = piece.matrix[0].length;
        const maxDim = Math.max(rows, cols);
        // Échelle uniforme pour chaque bloc : 14px (ou 12px pour forme de 5) pour loger sans déformation
        const cellSize = maxDim >= 5 ? 12 : 14;

        const pieceEl = createPieceElement(piece, cellSize);
        pieceEl.dataset.slot = i;
        attachDragHandlers(pieceEl, i);

        box.appendChild(pieceEl);
        slot.appendChild(box);
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

    // --- DRAG & DROP GÉOMÉTRIQUE SANS DÉCALAGE RESPONSIVE ---
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

      // Décalage vertical adaptatif proportionnel à l'écran (ne déborde jamais hors champ)
      const verticalOffset = Math.min(75, Math.max(50, window.innerHeight * 0.1));
      const visualCenterX = clientX;
      const visualCenterY = clientY - verticalOffset;

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

    // Écouteur de redimensionnement de fenêtre pour réajuster le dock
    window.addEventListener('resize', () => {
      renderDock();
    });

    // --- MOTEUR DE JEU ---
    function canPlace(matrix, startR, startC) {
      if (startR < 0 || startC < 0) return false;
      if (startR + matrix.length > SIZE || startC + matrix[0].length > SIZE) return false;
      for (let r = 0; r < matrix.length; r++) {
        for (let c = 0; c < matrix[r].length; c++) {
          if (matrix[r][c] > 0) {
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
            playRockCrush();
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
        setTimeout(() => p.remove(), 650);
      }
    }

    function runFinisherAnimation(animType, particleTheme, callback) {
      const colors = {
        neon: ['#00f2fe', '#ff00ff', '#00ff66', '#ffff00'],
        gold: ['#ffd700', '#ffb700', '#fff085', '#ff8c00'],
        crystal: ['#80ffff', '#00c6ff', '#0072ff', '#e0f7fa'],
        fireworks: ['#ff0844', '#ff6a00', '#fed929', '#8b5cf6', '#00f2fe']
      }[particleTheme] || ['#00f2fe', '#ffd700'];

      if (animType === 'missile_shower') {
        playMissileShowerSound();
        for (let m = 0; m < 4; m++) {
          setTimeout(() => {
            const missile = document.createElement('div');
            missile.className = 'finisher-missile';
            const col = Math.floor(Math.random() * 8);
            const targetRow = Math.floor(Math.random() * 4);
            const colCell = document.getElementById(`cell-${targetRow}-${col}`);
            if (colCell) {
              const rect = colCell.getBoundingClientRect();
              const boardRect = boardEl.getBoundingClientRect();
              missile.style.left = `${rect.left - boardRect.left + rect.width / 2 - 7}px`;
              missile.style.setProperty('--target-y', `${rect.top - boardRect.top}px`);
              particleContainer.appendChild(missile);
              setTimeout(() => {
                missile.remove();
                spawnThemeConfetti(rect.left - boardRect.left + rect.width/2, rect.top - boardRect.top, colors);
              }, 400);
            }
          }, m * 140);
        }
      } else if (animType === 'gem_explosion') {
        playGemExplosionSound();
        const shockwave = document.createElement('div');
        shockwave.className = 'giant-gem-shockwave';
        particleContainer.appendChild(shockwave);
        setTimeout(() => {
          shockwave.remove();
          const boardRect = boardEl.getBoundingClientRect();
          spawnThemeConfetti(boardRect.width / 2, boardRect.height / 2, colors, 35);
        }, 300);
      } else {
        playRainbowSweepSound();
        const sweepColors = ['#ff0844', '#ff6a00', '#fed929', '#00f5a0', '#00f2fe', '#38bdf8', '#8b5cf6', '#ff708d'];
        for (let c = 0; c < 8; c++) {
          setTimeout(() => {
            for (let r = 0; r < 8; r++) {
              const cell = document.getElementById(`cell-${r}-${c}`);
              if (cell) {
                cell.style.setProperty('--sweep-color', sweepColors[c]);
                cell.classList.add('rainbow-sweep');
                setTimeout(() => cell.classList.remove('rainbow-sweep'), 300);
              }
            }
          }, c * 60);
        }
        setTimeout(() => {
          const boardRect = boardEl.getBoundingClientRect();
          spawnThemeConfetti(boardRect.width / 2, boardRect.height / 2, colors, 25);
        }, 500);
      }

      setTimeout(callback, 850);
    }

    function spawnThemeConfetti(cx, cy, colors, count = 20) {
      for (let i = 0; i < count; i++) {
        const p = document.createElement('div');
        const color = colors[Math.floor(Math.random() * colors.length)];
        p.className = 'particle';
        p.style.backgroundColor = color;
        p.style.boxShadow = `0 0 10px ${color}`;
        p.style.left = `${cx}px`;
        p.style.top = `${cy}px`;
        p.style.width = '8px';
        p.style.height = '8px';
        const angle = Math.random() * Math.PI * 2;
        const dist = 35 + Math.random() * 85;
        p.style.setProperty('--dx', `${Math.cos(angle) * dist}px`);
        p.style.setProperty('--dy', `${Math.sin(angle) * dist}px`);
        particleContainer.appendChild(p);
        setTimeout(() => p.remove(), 650);
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
        
        let victory = false;
        if (level.goal === 'clear_jewels' && levelJewelsCollected >= level.target_value) victory = true;
        if (level.goal === 'clear_lines' && levelLinesCleared >= level.target_value) victory = true;
        if (level.goal === 'score' && levelScore >= level.target_value) victory = true;

        if (victory) {
          triggerLevelVictory();
          return;
        }

        if (movesRemaining !== null && movesRemaining <= 0) {
          triggerLevelDefeat("Limite de coups atteinte !");
          return;
        }
      }

      if (availablePieces.every(p => p === null)) {
        spawnTrio();
      } else {
        checkGameOver();
        persistCurrentGame();
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

    function triggerLevelVictory() {
      isGameOver = true;
      const level = ALL_LEVELS[currentLevelIndex];
      const thresholds = level.star_thresholds || {};
      const presentation = level.end_level_presentation || {};

      let stars = 1;

      let star2Achieved = false;
      if (thresholds.two_stars_moves_left !== null && thresholds.two_stars_moves_left !== undefined) {
        if (movesRemaining !== null && movesRemaining >= thresholds.two_stars_moves_left) {
          star2Achieved = true;
        }
      } else {
        star2Achieved = true;
      }
      if (star2Achieved) stars++;

      let star3Achieved = false;
      const scoreReq = thresholds.three_stars_score || 1000;
      if (levelScore >= scoreReq) {
        star3Achieved = true;
      }
      if (star3Achieved) stars++;

      LocalGameDB.clearCurrentState();
      if (!levelProgress.completed[level.level_id] || levelProgress.completed[level.level_id].stars < stars) {
        levelProgress.completed[level.level_id] = { stars, score: levelScore };
      }
      if (currentLevelIndex + 2 > levelProgress.unlockedLevel && levelProgress.unlockedLevel < ALL_LEVELS.length) {
        levelProgress.unlockedLevel = currentLevelIndex + 2;
      }
      LocalGameDB.saveLevelProgress(levelProgress);

      const animType = presentation.finisher_anim || 'grid_rainbow_sweep';
      const pTheme = presentation.particle_theme || 'neon';

      runFinisherAnimation(animType, pTheme, () => {
        document.getElementById('txtVictoryBanner').textContent = presentation.victory_banner || 'VICTOIRE !';
        document.getElementById('txtVictoryLevelTitle').textContent = `Niveau ${level.level_id} : ${level.title} (${level.world})`;
        document.getElementById('txtVictoryScore').textContent = levelScore;

        if (thresholds.two_stars_moves_left !== null) {
          document.getElementById('reqMovesStar2').textContent = `≥ ${thresholds.two_stars_moves_left} coups`;
          document.getElementById('statusStar2').textContent = star2Achieved ? '✓ Validé' : '✗ Non atteint';
          document.getElementById('statusStar2').className = star2Achieved ? 'font-bold text-amber-400' : 'font-bold text-gray-500';
        } else {
          document.getElementById('reqMovesStar2').textContent = 'Complété';
          document.getElementById('statusStar2').textContent = '✓ Validé';
          document.getElementById('statusStar2').className = 'font-bold text-amber-400';
        }

        document.getElementById('reqScoreStar3').textContent = `≥ ${scoreReq} pts`;
        document.getElementById('statusStar3').textContent = star3Achieved ? '✓ Validé' : '✗ Non atteint';
        document.getElementById('statusStar3').className = star3Achieved ? 'font-bold text-amber-400' : 'font-bold text-gray-500';

        for (let s = 1; s <= 3; s++) {
          const starEl = document.getElementById(`vStar-${s}`);
          starEl.className = 'text-gray-600 transition-all duration-300 transform scale-75';
        }

        document.getElementById('victoryModal').classList.remove('hidden');

        setTimeout(() => {
          document.getElementById('vStar-1').className = 'text-amber-400 transition-all duration-300 transform scale-110';
          playStarRevealSound(1);
        }, 220);

        if (stars >= 2) {
          setTimeout(() => {
            document.getElementById('vStar-2').className = 'text-amber-400 transition-all duration-300 transform scale-110';
            playStarRevealSound(2);
          }, 520);
        }

        if (stars >= 3) {
          setTimeout(() => {
            document.getElementById('vStar-3').className = 'text-amber-400 transition-all duration-300 transform scale-125 drop-shadow-[0_0_12px_#ffd700]';
            playStarRevealSound(3);
          }, 820);
        }
      });
    }

    function triggerLevelDefeat(reason) {
      isGameOver = true;
      LocalGameDB.clearCurrentState();
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
      LocalGameDB.clearCurrentState();
      LocalGameDB.saveHighScore(classicHighScore);
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
      LocalGameDB.clearCurrentState();
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

    let selectedWorldIndex = 0;

    function openLevelSelect() {
      isPaused = true;
      selectedWorldIndex = Math.floor(currentLevelIndex / 10);
      updateWorldTabsUI();
      renderLevelGrid();
      document.getElementById('levelSelectModal').classList.remove('hidden');
    }

    function closeLevelSelect() {
      document.getElementById('levelSelectModal').classList.add('hidden');
      isPaused = false;
    }

    function updateWorldTabsUI() {
      for (let w = 0; w < 5; w++) {
        const btn = document.getElementById(`worldTab-${w}`);
        if (!btn) continue;
        if (w === selectedWorldIndex) {
          btn.className = 'world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-cyan-500 text-black shadow-md shadow-cyan-500/30';
        } else {
          btn.className = 'world-tab btn-action px-2.5 sm:px-3 py-1.5 rounded-xl text-[11px] sm:text-xs font-bold whitespace-nowrap bg-[#1d1e30] text-gray-300 hover:bg-[#252742]';
        }
      }
    }

    function renderLevelGrid() {
      const gridContainer = document.getElementById('levelCardsGrid');
      gridContainer.innerHTML = '';
      const startIdx = selectedWorldIndex * 10;
      const endIdx = startIdx + 10;

      for (let i = startIdx; i < endIdx && i < ALL_LEVELS.length; i++) {
        const lvl = ALL_LEVELS[i];
        const isUnlocked = lvl.level_id <= levelProgress.unlockedLevel;
        const comp = levelProgress.completed[lvl.level_id];
        const stars = comp ? comp.stars : 0;
        const isCurrent = i === currentLevelIndex;

        const card = document.createElement('button');
        card.type = 'button';
        card.className = `btn-action flex flex-col items-center justify-center p-1.5 sm:p-2 rounded-xl sm:rounded-2xl border transition-all ${
          isCurrent
            ? 'bg-cyan-500/25 border-cyan-400 shadow-md shadow-cyan-500/30'
            : isUnlocked
            ? 'bg-[#1b1c31] border-white/10 hover:border-white/30 text-white'
            : 'bg-[#131422] border-white/5 opacity-40 cursor-not-allowed text-gray-500'
        }`;

        const numSpan = document.createElement('span');
        numSpan.className = 'font-black text-xs sm:text-sm font-num';
        numSpan.textContent = isUnlocked ? lvl.level_id : '🔒';
        card.appendChild(numSpan);

        if (isUnlocked) {
          const starBox = document.createElement('div');
          starBox.className = 'flex text-[8px] sm:text-[9px] mt-0.5 sm:mt-1';
          for (let s = 1; s <= 3; s++) {
            const star = document.createElement('span');
            star.textContent = '★';
            star.className = s <= stars ? 'text-amber-400' : 'text-gray-600';
            starBox.appendChild(star);
          }
          card.appendChild(starBox);

          card.addEventListener('click', () => {
            closeLevelSelect();
            switchMode('levels');
            loadLevel(i);
          });
        }

        gridContainer.appendChild(card);
      }
    }

    function switchMode(mode, fromRestore = false) {
      gameMode = mode;
      if (mode === 'levels') {
        tabModeLevels.className = 'btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-md';
        tabModeClassic.className = 'btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all text-gray-400 hover:text-white';
        hudLevels.classList.remove('hidden');
        hudClassic.classList.add('hidden');
        if (!fromRestore) {
          LocalGameDB.clearCurrentState();
          loadLevel(currentLevelIndex);
        }
      } else {
        tabModeClassic.className = 'btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all bg-gradient-to-r from-amber-500 to-orange-600 text-white shadow-md';
        tabModeLevels.className = 'btn-action px-3 sm:px-3.5 py-1.5 rounded-full text-[11px] sm:text-xs font-bold transition-all text-gray-400 hover:text-white';
        hudLevels.classList.add('hidden');
        hudClassic.classList.remove('hidden');
        if (!fromRestore) {
          LocalGameDB.clearCurrentState();
          restartCurrentGame();
        }
      }
    }

    // Réglage instantané du son (action immédiate dès le premier appui tactile)
    function toggleSound() {
      initAudio();
      soundEnabled = !soundEnabled;
      LocalGameDB.saveSettings({ soundEnabled });
      updateSoundUI();
    }

    function updateSoundUI() {
      const icon = soundEnabled ? '🔊' : '🔇';
      const status = soundEnabled ? 'ACTIF' : 'MUET';
      const soundIcon = document.getElementById('soundIcon');
      const soundIconPause = document.getElementById('soundIconPause');
      const soundStatusPause = document.getElementById('soundStatusPause');
      const btnSound = document.getElementById('btnSound');

      if (soundIcon) soundIcon.textContent = icon;
      if (soundIconPause) soundIconPause.textContent = icon;
      if (soundStatusPause) soundStatusPause.textContent = status;
      if (btnSound) btnSound.classList.toggle('opacity-50', !soundEnabled);
    }

    // Gestionnaire d'action réactif sans double-clic parasite (fonctionnement instantané)
    const attachButtonHandler = (id, handler) => {
      const el = document.getElementById(id);
      if (!el) return;
      let lastTrigger = 0;
      const trigger = (e) => {
        const now = Date.now();
        if (now - lastTrigger < 320) return; // Ignore l'événement synthétique ultérieur
        lastTrigger = now;
        e.preventDefault();
        e.stopPropagation();
        handler(e);
      };
      el.addEventListener('pointerdown', trigger, { passive: false });
      el.addEventListener('click', trigger, { passive: false });
    };

    attachButtonHandler('tabModeLevels', () => switchMode('levels'));
    attachButtonHandler('tabModeClassic', () => switchMode('classic'));
    attachButtonHandler('btnOpenLevelSelect', () => openLevelSelect());
    attachButtonHandler('btnCloseLevelSelect', () => closeLevelSelect());

    for (let w = 0; w < 5; w++) {
      attachButtonHandler(`worldTab-${w}`, () => {
        selectedWorldIndex = w;
        updateWorldTabsUI();
        renderLevelGrid();
      });
    }

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

    function restoreSavedGame(saved) {
      gameMode = saved.gameMode || 'levels';
      currentLevelIndex = saved.currentLevelIndex || 0;
      grid = saved.grid.map(row => [...row]);
      comboStreak = saved.comboStreak || 0;
      isGameOver = false;
      isPaused = false;

      if (saved.availablePieces && Array.isArray(saved.availablePieces)) {
        availablePieces = saved.availablePieces.map(p => {
          if (!p || !p.matrix) return null;
          return {
            matrix: p.matrix.map(r => [...r]),
            color: p.color
          };
        });
      } else {
        availablePieces = [null, null, null];
      }

      if (gameMode === 'levels') {
        levelScore = saved.levelScore || 0;
        levelLinesCleared = saved.levelLinesCleared || 0;
        levelJewelsCollected = saved.levelJewelsCollected || 0;
        movesRemaining = saved.movesRemaining !== undefined ? saved.movesRemaining : null;
        switchMode('levels', true);
        updateLevelHUD();
      } else {
        classicScore = saved.classicScore || 0;
        switchMode('classic', true);
        updateClassicScore();
      }

      renderBoard();
      renderDock();
      checkGameOver();
    }

    // Initialisation et démarrage via la base de données locale
    const savedSettings = LocalGameDB.loadSettings();
    soundEnabled = savedSettings.soundEnabled !== false;
    updateSoundUI();

    const savedGame = LocalGameDB.loadCurrentState();
    if (savedGame && !savedGame.isGameOver && savedGame.grid && Array.isArray(savedGame.grid)) {
      restoreSavedGame(savedGame);
    } else {
      // Démarrer automatiquement au niveau atteint (plus haut niveau débloqué)
      const targetLevel = Math.min(Math.max(0, (levelProgress.unlockedLevel || 1) - 1), ALL_LEVELS.length - 1);
      loadLevel(targetLevel);
    }
  </script>
</body>
</html>
"""

for p in ['/root/block-blast-android/web_preview/index.html', '/root/block_blast_android/web_preview/index.html']:
    with open(p, 'w', encoding='utf-8') as f:
        f.write(html_template)

print("web_preview/index.html successfully updated with responsive design!")
