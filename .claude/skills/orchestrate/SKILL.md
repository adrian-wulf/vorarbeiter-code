---
name: orchestrate
description: Uruchamia lub wznawia pętlę orkiestracji — dla każdego zadania z kolejki pisze zlecenie, wywołuje wykonawcę (agy/gemini/codex) przez executor/run.sh, samodzielnie weryfikuje wynik i commituje albo odsyła z konkretnym feedbackiem (limit 4 prób). Używaj, gdy użytkownik wpisze /orchestrate, „kontynuuj pętlę”, „wznów” albo po zaakceptowaniu kolejki zadań.
---

# /orchestrate — pętla: zlecenie → weryfikacja → commit

Pełny algorytm, kontrakt zlecenia i checklista weryfikacji są
w `ORCHESTRATION.md` — przeczytaj go przed pierwszym zadaniem sesji.
Nie piszesz kodu sam (CLAUDE.md, reguła 1).

## Start / wznowienie

1. Przeczytaj `ORCHESTRATION_STATE.md` (aktualne zadanie, kolejka, historia,
   **Lekcje**), `AGENTS.md`, `ROADMAP.md`.
2. Sprawdź gałąź (`git branch --show-current`) i `git status`.
   - Niezacommitowane zmiany przy zadaniu „w trakcie” = wynik ostatniej
     próby, który nie przeszedł weryfikacji albo nie został sprawdzony →
     zweryfikuj go (krok 5), zanim zlecisz cokolwiek nowego.
   - Zadanie „zablokowane” → nie ruszaj; zapytaj użytkownika, co dalej.
3. `bash executor/preflight.sh` (raz na sesję). NIEGOTOWE → powiedz, co
   naprawić, i zakończ.
4. Powiedz użytkownikowi jednym zdaniem, od którego zadania startujesz.

## Dla każdego zadania

1. **Stan PRZED:** `bash executor/verify.sh > .executor-logs/<ID>-before.txt 2>&1`
   — zanotuj liczbę testów i metryki, których zadanie może dotknąć.
2. **Zlecenie:** zapisz `.executor-logs/<ID>-p<n>.brief.md` wg kontraktu
   z `ORCHESTRATION.md` §3. Wskaż konkretne sekcje dokumentów. W próbie > 1
   — konkretny feedback z poprzedniej weryfikacji.
3. **Wywołanie** (w tle, z informacją dla użytkownika o spodziewanym czasie):
   ```bash
   bash executor/run.sh .executor-logs/<ID>-p<n>.brief.md write .executor-logs/<ID>-p<n>.log
   ```
   Kod 3 → zadanie „zablokowane — limit wykonawcy”, zapis w stanie, STOP
   (bez commita). Kod 4 → poproś o zalogowanie wykonawcy, STOP.
   Kod 1 → przeczytaj log; drugi raz z rzędu pusty/niezrozumiały → jak kod 3.
4. **Przeczytaj raport** z logu — szczególnie „Czego NIE zrobiono”.
5. **Weryfikacja** — checklista z `ORCHESTRATION.md` §5, punkt po punkcie.
   Porównaj z `<ID>-before.txt`. Dla UI: uruchom aplikację i zrób zrzut ekranu
   (sposób: `ARCHITECTURE.md` → „Środowisko agenta”).
6. **Wynik:**
   - ✅ spełnione → `git add` tylko plików z zakresu → commit
     `<ID>: <opis> — via <wykonawca>, zweryfikowane` (+ stopka
     Co-Authored-By, jeśli projekt jej używa) → w stanie: historia,
     „Ukończone zadania” z hashem, licznik prób 0 → następne zadanie.
   - ❌ niespełnione → próba + 1, wpis w historii (co zlecono / co wyszło /
     co nie tak). Próba < 4 → wróć do 2 z konkretnym feedbackiem.
     Próba = 4 → „zablokowane”, pełny opis problemu, STOP.
7. **Lekcje:** nowy wniosek → `## Lekcje` (`LEKCJA: …`). Ten sam błąd
   wykonawcy drugi raz → nowy punkt w `executor/rules.md`
   (lub `executor/rules.profile.md` dla spraw stacku) i krótka
   informacja dla użytkownika.
8. Sprawdź, czy użytkownik czegoś nie napisał.

## Koniec milestone'a

Po ostatnim zadaniu kolejki:
1. `bash executor/verify.sh` na całości; sprawdź kryterium milestone'a
   z `ROADMAP.md`.
2. ROADMAP: milestone → ✅; stan: podsumowanie w historii.
3. Commit stanu. **STOP** — raport dla użytkownika: co zrobiono, co
   warto przetestować ręcznie (playtest), lekcje, propozycja merge
   gałęzi do `main` (merge tylko po zgodzie) i następny milestone.
