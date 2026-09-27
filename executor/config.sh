# Konfiguracja wykonawcy. Każdą wartość można nadpisać zmienną środowiskową.
# EXECUTOR: agy (domyślny) | gemini | codex | fake (tylko testy)
EXECUTOR="${EXECUTOR:-agy}"
# Model; pusty = domyślny wykonawcy. agy: lista w `agy models` (np. gemini-3.8-flash-high)
EXECUTOR_MODEL="${EXECUTOR_MODEL:-}"
# Limit czasu jednego zlecenia w sekundach
EXECUTOR_TIMEOUT="${EXECUTOR_TIMEOUT:-1800}"
