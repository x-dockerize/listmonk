#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"
CONFIG_TEMPLATE=".docker/listmonk/config/config.toml.template"
CONFIG_FILE=".docker/listmonk/config/config.toml"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$CONFIG_TEMPLATE" ]; then
  echo "❌ $CONFIG_TEMPLATE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
gen_password() {
  openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 20
}

set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "LISTMONK_SERVER_HOSTNAME (örn: newsletter.example.com): " LISTMONK_SERVER_HOSTNAME

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env LISTMONK_SERVER_HOSTNAME "$LISTMONK_SERVER_HOSTNAME"

# --------------------------------------------------
# config.toml (mevcut değilse template'den oluştur)
# --------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
  DB_PASSWORD="$(gen_password)"
  sed "s|password = \"super-strong-password\"|password = \"${DB_PASSWORD}\"|" \
    "$CONFIG_TEMPLATE" > "$CONFIG_FILE"
  echo "✅ $CONFIG_FILE oluşturuldu"
else
  echo "ℹ️  $CONFIG_FILE mevcut, dokunulmadı"
  DB_PASSWORD=$(grep 'password' "$CONFIG_FILE" | head -1 | sed 's/.*= "\(.*\)"/\1/')
fi

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Listmonk yapılandırması hazırlandı"
echo "-----------------------------------------------"
echo "🌐 Hostname      : $LISTMONK_SERVER_HOSTNAME"
echo "🔑 DB Şifresi    : $DB_PASSWORD"
echo "-----------------------------------------------"
echo "⚠️  Şifreyi güvenli bir yerde saklayın!"
echo "==============================================="
