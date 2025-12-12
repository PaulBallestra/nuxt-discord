<script setup lang="ts">
const client = useSupabaseClient()

const { data: instruments } = await useAsyncData('instrument', async () => {
  const { data } = await client.from('instruments').select('id, name')
  return data
})
</script>


<template>
  <ul v-if="instruments">
    <li v-for="instrument in instruments" :key="instrument.id">{{ instrument.name }}</li>
  </ul>
</template>