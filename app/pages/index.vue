<script setup lang="ts">
const data = await useFetch('/api/route')
</script>

<template>
  <pre>{{data}}</pre>
</template>
