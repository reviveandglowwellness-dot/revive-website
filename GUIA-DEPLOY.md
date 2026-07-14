# Guia de Deploy — reviveandglowwellness.com

> Passo-a-passo pra colocar o site no ar na Vercel, com o domínio do GoDaddy.
> Você faz cada passo nas SUAS contas. A Glowria preparou os arquivos; a publicação é você que clica.
> Regra de segurança: só sobem os arquivos da pasta `meu-negocio/website/`. NUNCA o repositório de gestão.

## Arquivos que vão pro ar (pasta `meu-negocio/website/`)
- `index.html` — a página
- `favicon.svg` — ícone da aba
- `robots.txt` — instrução pros buscadores
- `sitemap.xml` — mapa do site pro Google

---

## PASSO 1 — Criar um repositório novo no GitHub (só do site)

1. Entre em **github.com** (logada na sua conta).
2. Botão verde **New** (novo repositório).
3. Nome: `revive-website` (ou o que preferir).
4. Deixe **Public**. NÃO marque "Add a README".
5. Clique **Create repository**.
6. Na página seguinte, clique no link **"uploading an existing file"**.
7. **Arraste os 4 arquivos** da pasta `meu-negocio/website/` (index.html, favicon.svg, robots.txt, sitemap.xml) pra área de upload.
8. Clique **Commit changes**.

✅ Pronto — o código do site está no GitHub.

---

## PASSO 2 — Publicar na Vercel

1. Entre em **vercel.com** e faça login **com o GitHub** (botão "Continue with GitHub").
2. Clique **Add New… → Project**.
3. Encontre o repositório `revive-website` e clique **Import**.
4. Não precisa mexer em nada (é site estático). Clique **Deploy**.
5. Espere ~1 minuto. A Vercel te dá um link tipo `revive-website.vercel.app`.

✅ O site já está no ar nesse link temporário. Abra e confira.

---

## PASSO 3 — Ligar o seu domínio (reviveandglowwellness.com)

### Na Vercel:
1. Dentro do projeto, vá em **Settings → Domains**.
2. Digite `reviveandglowwellness.com` e clique **Add**.
3. A Vercel vai MOSTRAR os registros de DNS exatos que você precisa copiar (um registro **A** pro domínio raiz e/ou um **CNAME** pro `www`). **Use os valores que a Vercel mostrar** — eles são a fonte da verdade.

### No GoDaddy:
4. Entre em **godaddy.com → My Products → DNS** do domínio reviveandglowwellness.com.
5. Adicione/edite os registros **exatamente** como a Vercel pediu:
   - Registro **A** → Host `@` → valor que a Vercel mostrou
   - Registro **CNAME** → Host `www` → valor que a Vercel mostrou (geralmente `cname.vercel-dns.com`)
6. Salve.

⏳ O DNS pode levar de alguns minutos a algumas horas pra propagar. Quando terminar, a Vercel mostra "Valid Configuration" e o site abre em **reviveandglowwellness.com** com cadeado (HTTPS automático).

---

## FASE 2 (depois do site no ar) — Fazer o waitlist capturar de verdade

Hoje o formulário mostra a mensagem de "obrigada", mas ainda NÃO salva o contato. Pra virar captação real (sem precisar de programador), o caminho mais fácil é um serviço de formulário gratuito (ex.: Formspree) ou ligar direto no Mindbody quando a conta estiver ativa. A Glowria monta isso com você quando chegar a hora.

## Como ATUALIZAR o site depois (ex.: trocar por fotos reais na abertura)
- Edite o arquivo no GitHub (ou a Glowria edita e você sobe de novo) → a Vercel republica sozinha em segundos. Nada de refazer nada.

---

> Dúvida em qualquer passo? Chama a Glowria que ela te guia na tela.
