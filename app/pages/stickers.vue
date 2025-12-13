<script setup lang="ts">
import StickerCard from '~/components/StickerCard.vue';

const STICKERS = [
    {
        main: 'images/space-sticker.png',
        mask: 'images/space-sticker-mask.png',
        width: 513,
        height: 430,
    },
    {
        main: 'images/sticker.png',
        mask: 'images/sticker-mask.png',
        width: 666,
        height: 616
    },
    {
        main: 'images/skateboard-sticker.png',
        mask: 'images/skateboard-sticker-mask.png',
        width: 500,
        height: 500
    },
]

</script>
<template>
    <ul class="flex flex-col lg:flex-row items-center justify-center gap-8">
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