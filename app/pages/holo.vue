<template>
  <div class="card"></div>
</template>

<style>
.card {
  width: 300px;
  height: 420px;
  border-radius: 12px;
  background:
    conic-gradient(from 0deg,
      #ff00ff,
      #00ffff,
      #ffff00,
      #ff00ff);
  background-size: 200% 200%;
  animation: holo 6s linear infinite;
  filter: brightness(1.2) contrast(1.3) saturate(1.8);
  box-shadow: 0 0 20px rgba(255, 255, 255, 0.4);
  position: relative;
  overflow: hidden;
}

@keyframes holo {
  0% {
    background-position: 0% 50%;
  }

  50% {
    background-position: 100% 50%;
  }

  100% {
    background-position: 0% 50%;
  }
}
</style>