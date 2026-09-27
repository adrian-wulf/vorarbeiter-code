# MODULES/

Ten folder zawiera osobne, małe dokumenty `.md` dla każdego kluczowego
modułu projektu — zamiast jednego wielkiego dokumentu. Dzięki temu agentowi
LLM łatwiej wrzucić do kontekstu tylko to, co potrzebne do konkretnego
zadania, bez zaśmiecania go resztą projektu.

## Kiedy tworzyć nowy plik tutaj

Przy rozpoczynaniu pracy nad nowym, samodzielnym modułem. Plik powstaje
**przy pracy nad danym modułem**, nie na zapas.

## Konwencja nazywania

`MODULE_<nazwa>.md`, np.:

- `MODULE_auth.md` — logowanie, sesje, uprawnienia
- `MODULE_billing.md` — płatności, faktury, webhooki
- `MODULE_import.md` — import danych, walidacja, błędy

## Co powinien zawierać dokument modułu

- Krótki opis odpowiedzialności modułu (co robi, czego NIE robi).
- Publiczny interfejs (funkcje, endpointy, zdarzenia).
- Kluczowe dane/struktury.
- Zależności od innych modułów i usług zewnętrznych.
- Jak go testować.
- Otwarte pytania/decyzje do podjęcia.
