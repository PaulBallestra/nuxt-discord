<script setup lang="ts">
import StickerCard from '~/components/StickerCard.vue';

const STICKERS = [
    {
        main: 'space-sticker.png',
        mask: 'space-sticker-mask.png',
        width: 513,
        height: 430,
    },
    {
        main: 'sticker.png',
        mask: 'sticker-mask.png',
        width: 666,
        height: 616
    }
]

</script>
<template>
    <ul class="flex items-center justify-center gap-8">
        <li v-for="sticker in STICKERS" :key="sticker.main">
            <StickerCard v-bind="sticker" />
        </li>
    </ul>
</template>

<style>
ul {
    perspective: 1200px;
}
</style>