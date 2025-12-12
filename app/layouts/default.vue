<template>
  <UApp>
    <div class="bg-black">
      <div class="h-[2vh]">
        <p>Some default layout content shared across all pages</p>
      </div>
      <div class="min-w-screen h-[98vh] grid place-content-center">
        <slot />
      </div>
    </div>
  </UApp>
</template>
