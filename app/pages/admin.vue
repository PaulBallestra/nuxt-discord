<script setup lang="ts">
definePageMeta({
    layout: 'admin-nav'
})
const session = useSupabaseSession()
const user = useSupabaseUser()
</script>

<template>
    Admin
    <br>
    Session
    {{ session }}
    <br>
    User
    {{ user }}
</template>