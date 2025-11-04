# Supabase Auth App Example

Aplicativo Flutter conectado ao Supabase demonstrando autenticação por e‑mail e gerenciamento de perfil.

## Pré-requisitos Supabase

Execute o SQL abaixo no seu projeto Supabase para criar a tabela `profiles` vinculada aos usuários:

```sql
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  cpf text,
  phone text,
  profile_image_url text,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

alter table public.profiles
  enable row level security;

create policy "Users can manage own profile"
on public.profiles
for all
using (auth.uid() = id)
with check (auth.uid() = id);
```

Crie ainda um bucket de armazenamento chamado `profile_images` (com RLS ativado) e adicione esta política:

```sql
create policy "Users can manage their profile image"
on storage.objects
for all
using (
  bucket_id = 'profile_images'
  and auth.uid() = owner
)
with check (
  bucket_id = 'profile_images'
  and auth.uid() = owner
);
```

## Rodando o projeto

1. Configure as variáveis do Supabase em `lib/main.dart`.
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o app:
   ```bash
   flutter run
   ```
