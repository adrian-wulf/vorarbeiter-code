---
name: kickoff
description: Start nowego projektu programistycznego — prowadzi wywiad z użytkownikiem (problem i cel, pierwsze 5 minut użytkownika, stack) i tworzy komplet dokumentów projektu jeden po drugim (AGENTS, PRD, ARCHITECTURE, ROADMAP, CODING_STYLE, UI_STYLE, GLOSSARY, DECISIONS, MODULES), konfiguruje executor/verify.sh pod wybrany stack i wykonawcę. Używaj, gdy użytkownik wpisze /kickoff, chce zacząć nowy projekt albo AGENTS.md ma jeszcze placeholdery {{…}}. Wznawialny.
---

# /kickoff — od pomysłu do kompletu dokumentów

Prowadzisz rozmowę jak doświadczony product manager i tech lead w jednym.
Cel: dokumenty, dzięki którym wykonawca (agy) może budować projekt bez
zgadywania, a Ty możesz go nadzorować. Dokumenty to jedyna pamięć projektu
między sesjami — piszesz je dla agenta LLM, nie dla prezentacji.

## Zasady rozmowy (obowiązują w KAŻDEJ fazie)

1. **Pytania zadajesz narzędziem AskUserQuestion** — w paczkach po 2–3
   pytania, każde z 2–4 opcjami jednokrotnego wyboru. (Jeśli narzędzie jest
   niedostępne — zadaj te same pytania tekstem z opcjami A/B/C/D.)
2. **Ostatnia opcja każdego pytania to zawsze „Nie wiem, zaproponuj”.**
   Użytkownik nie musi znać odpowiedzi — Ty jesteś ekspertem.
3. Przy „Nie wiem, zaproponuj”: podajesz **jedną** rekomendację + 1–2 zdania
   uzasadnienia (dlaczego pasuje do TEGO projektu, jego użytkowników
   i ograniczeń) i od razu dopisujesz wpis do `DECISIONS.md`:
   ```markdown
   **Decyzja:** …
   **Uzasadnienie:** …
   **Odrzucone alternatywy:** …
   ```
   Tak samo zapisujesz każdą istotną decyzję użytkownika.
4. **Bramka przed każdym dokumentem** — AskUserQuestion:
   „Mam komplet do <X>.md?” → opcje „Tak, pisz” / „Jeszcze doprecyzujmy”.
   Przy „doprecyzujmy” zadajesz kolejną paczkę pytań i wracasz do bramki.
5. Po zapisaniu dokumentu: 3–5 zdań podsumowania najważniejszych ustaleń
   + pytanie „Kontynuować do <Y>.md?”. Aktualizujesz `## Kickoff`
   w `ORCHESTRATION_STATE.md` i tabelę statusu w `AGENTS.md`.
5a. **Po każdej paczce odpowiedzi** dopisujesz ustalenia (jedna linia
   na ustalenie) do `### Ustalenia` pod `## Kickoff`
   w `ORCHESTRATION_STATE.md` — także w fazach 1–3, zanim powstanie
   jakikolwiek dokument. To jedyne, co ratuje rozmowę przerwaną w połowie.
6. **Jeden dokument naraz.** Nie piszesz kilku dokumentów w jednej turze.
7. Dokumenty tworzysz z szablonów w `docs-templates/`. Zastępujesz wszystkie
   `{{…}}` i usuwasz komentarze `<!-- kickoff: … -->`. Sekcja, do której
   nie ma danych, trafia do „Otwarte pytania” — nigdy nie zostaje pusta.
8. Pytaj o to, co zmienia projekt, nie o oczywistości. Jeśli odpowiedź wynika
   z wcześniejszych ustaleń — nie pytaj, zapisz.
9. Rozmawiasz po polsku, konkretnie, bez lania wody.

## Start

Najpierw sprawdź `command -v jq` — bez jq hook ochronny blokuje każdą
edycję; poproś wtedy o instalację jq, zanim zaczniesz. Następnie utwórz
`DECISIONS.md` z `docs-templates/DECISIONS.md` (zostaw tylko nagłówek
i wstęp) — wpisy decyzji dopisujesz w nim od pierwszej paczki pytań.

## Wznawianie

Na starcie przeczytaj `## Kickoff` (w tym `### Ustalenia`)
w `ORCHESTRATION_STATE.md`. Jeśli faza
lub któryś dokument są już zrobione — powiedz krótko, na czym skończyliście,
i kontynuuj od pierwszego ⬜. Nie powtarzaj pytań, na które są już
odpowiedzi w dokumentach.

## Faza 1 — Problem i cel

1. Zapytaj (paczka): jaki problem rozwiązujemy i dla kogo (ja sam / zespół /
   klienci / publicznie), jak wygląda sukces (mierzalnie, jeśli się da),
   czy to prototyp, produkt czy narzędzie wewnętrzne.
2. Ustal, co jest **poza zakresem** — to równie ważne jak zakres.
3. Zaproponuj **2–3 warianty zakresu MVP** (od najmniejszego sensownego
   do ambitnego), każdy z 2–3 zdaniami: co zawiera, czego nie, ile to
   milestone'ów. Zapytaj o wybór.

## Faza 2 — Pierwsze 5 minut użytkownika

Opisz krok po kroku scenariusz: użytkownik po raz pierwszy wchodzi w kontakt
z projektem (otwiera stronę / instaluje CLI / woła API / importuje
bibliotekę) → co widzi, co robi, jaki efekt dostaje. To test, czy MVP ma
sens. Zapytaj, co zmienić. Ten opis trafi do `PRD.md`.

## Faza 3 — Stack

Paczki pytań: typ projektu (web app / API / CLI / biblioteka / skrypt /
mobile / desktop), język, framework, baza danych, hosting/deploy, czy jest
UI. Rekomendując, bierz pod uwagę: typ projektu, doświadczenie użytkownika,
koszt utrzymania, dojrzałość ekosystemu, to, jak dobrze tani model radzi
sobie z danym stackiem (popularne stacki = mniej błędów wykonawcy).

Po wyborze stacku **napisz `executor/verify.sh`** — pełną weryfikację
projektu w kolejności: formatowanie/lint → typecheck → testy → build.
Kontrakt: exit 0 = wszystko zielone; każdy krok wypisuje, co sprawdził;
zero testów = porażka (nie „zielono”). Przykład dla TypeScript:

```bash
#!/usr/bin/env bash
# Weryfikacja projektu: lint → typecheck → testy → build.
set -uo pipefail
rc=0
step() { echo "== $1"; shift; "$@" || { echo "FAIL: $*"; rc=1; }; }
step "lint"      npx eslint .
step "typecheck" npx tsc --noEmit
step "testy"     npx vitest run
step "build"     npm run build
exit $rc
```

Dopisz do `.gitignore` artefakty stacku (np. `node_modules/`, `dist/`,
`__pycache__/`, `.venv/`, `target/`, `.env`) — zanim wykonawca cokolwiek
zbuduje.

Wzorzec `CODING_STYLE.md`: `docs-templates/coding-style/<język>.md`, jeśli
istnieje (typescript, python, go, rust); w przeciwnym razie piszesz
CODING_STYLE z wywiadu. Zasady specyficzne dla stacku, które warto
doklejać do każdego zlecenia, zapisz w `executor/rules.profile.md`
(nagłówek `## ZASADY STACKU: <stack>`, 3–6 punktów).

## Faza 4 — Dokumenty (po kolei)

`DECISIONS.md` już istnieje (założony na starcie, z wpisami z faz 1–3).
Kolejność pozostałych:

| # | Dokument | Szablon | O co pytać (przykłady) |
|---|---|---|---|
| 1 | `AGENTS.md` | ten w roocie | wypełnij placeholdery z faz 1–3 |
| 2 | `PRD.md` | `docs-templates/PRD.md` | persony, scenariusze, wymagania funkcjonalne, niefunkcjonalne (wydajność, bezpieczeństwo, prywatność, dostępność), kryteria akceptacji |
| 3 | `ARCHITECTURE.md` | `docs-templates/ARCHITECTURE.md` | struktura katalogów, model danych, API/interfejsy, obsługa błędów, logowanie, konfiguracja i sekrety, testy, deploy |
| 4 | `ROADMAP.md` | `docs-templates/ROADMAP.md` | co jest M0 (szkielet + pierwszy przepływ end-to-end), kolejność, co poza MVP |
| 5 | `CODING_STYLE.md` | `docs-templates/coding-style/<język>.md` | formatter/linter, typowanie, nazewnictwo, obsługa błędów, testy |
| 6 | `UI_STYLE.md` *(tylko jeśli jest UI)* | `docs-templates/UI_STYLE.md` | biblioteka komponentów, typografia, kolory, responsywność, dostępność |
| 7 | `GLOSSARY.md` | `docs-templates/GLOSSARY.md` | pojęcia domenowe, nazwy encji i pól, komunikaty dla użytkownika |
| 8 | `MODULES/README.md` | `docs-templates/MODULES_README.md` | nic — tylko utwórz; pliki modułów powstają przy pracy nad nimi |

W `ARCHITECTURE.md` sekcja „Jak uruchomić / testować” musi zawierać
dokładne komendy (instalacja zależności, uruchomienie, pojedynczy test,
wszystkie testy = `bash executor/verify.sh`), a sekcja „Weryfikacja UI”
(jeśli jest UI) — jak uruchomić aplikację i zrobić zrzut ekranu
(claude-in-chrome albo Playwright).

## Faza 5 — Setup wykonawcy

1. `bash executor/preflight.sh` — wynik wpisz do `## Wykonawca`
   w `ORCHESTRATION_STATE.md` (wykonawca, wersja, model, data).
   Jeśli NIEGOTOWE — powiedz dokładnie, co naprawić, i poczekaj.
2. Uprzedź, że `executor/verify.sh` przejdzie dopiero po M0 (szkielet
   projektu) — pierwsze zadanie M0 ma go zazielenić.
3. Licencja projektu — zapytaj (AskUserQuestion): „Na jakiej licencji
   ma być projekt?” → „Zamknięty (bez licencji)” / „MIT na moje nazwisko”
   / „Inna — podam”. `LICENSE` szablonu dotyczy szablonu, nie projektu.
4. Sprzątanie szablonu (pliki szablonu nie mogą zostać w projekcie):
   ```bash
   git rm -r -q docs-templates/ tests/ README.en.md LICENSE
   ```
   - `README.md` zastąp krótkim README projektu (nazwa, problem z PRD,
     jak uruchomić z ARCHITECTURE, stopka „Projekt prowadzony metodą
     Vorarbeiter — Claude Code nadzoruje, agy koduje” z linkiem do
     szablonu). Bez odznak wsparcia, Impressum i danych autora szablonu.
   - `LICENSE` — nowy wg odpowiedzi z kroku 3 (albo brak pliku).
   - `NOTICE` zostaje (atrybucje szablonu i skilla antigravity-agents).
5. Commit: `docs: kickoff — komplet dokumentów projektu`.
6. Ustaw `## Kickoff` → „Faza: zakończony”. Zaproponuj `/plan-milestone`
   dla M0.
