<script setup lang="ts">
import * as v from 'valibot'
import type { FormSubmitEvent } from '@nuxt/ui'

const loading = ref(false)
const message = ref<string | null>(null)
const errorMsg = ref<string | null>(null)
const supabase = useSupabaseClient()

const schema = v.object({
  email: v.pipe(v.string(), v.email('Invalid email')),
  password: v.pipe(v.string(), v.minLength(8, 'Must be at least 8 characters'))
})

type Schema = v.InferOutput<typeof schema>

const state = reactive({
  email: '',
  password: ''
})

async function onGoogleAuth(){
  console.log('google auth')
}

async function onSubmit(event: FormSubmitEvent<Schema>) {
  console.log(event.data)

  loading.value = true
  errorMsg.value = null
  message.value = null

  const { error } = await supabase.auth.signInWithOtp({
    email: state.email,
    options: {
      emailRedirectTo: 'http://localhost:3000/confirm',
    }
  })

  loading.value = false

  if (error) {
    errorMsg.value = error.message
  } else {
    message.value = "Un email de connexion vient d'être envoyé."
  }
}
</script>

<template>
  <UForm
    :schema="schema"
    :state="state"
    @submit="onSubmit"
    class="max-w-sm mx-auto p-4 space-y-4 bg-black shadow rounded"
  >
    <h2 class="text-xl font-semibold">Connexion</h2>

    <UFormField  label="Email" name="email">
      <UInput v-model="state.email" type="email" placeholder="Votre email" />
    </UFormField >

    <UFormField  label="Mot de passe" name="password">
      <UInput v-model="state.password" type="password" placeholder="Mot de passe" />
    </UFormField>

    <UButton type="submit" :loading="loading" block>
      Se connecter
    </UButton>

    <p v-if="message" class="text-green-600">{{ message }}</p>
    <p v-if="errorMsg" class="text-red-600">{{ errorMsg }}</p>
  </UForm>

  <button type="button" @click="onGoogleAuth" class="cursor-pointer bg-black">google auth</button>
</template>
