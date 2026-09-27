# ORCHESTRATION.md — Brygadzista zleca, wykonawca koduje

> Instrukcja dla Claude Code (kierownika). Opisuje pętlę, w której Claude
> przechodzi przez `ROADMAP.md` zadanie po zadaniu: zleca każde wykonawcy,
> weryfikuje wynik i poprawia w pętli, aż zadanie faktycznie spełni
> kryterium ukończenia. Stan pętli żyje w `ORCHESTRATION_STATE.md`.

## 1. Koncepcja

Kierownik (Claude Code) rozumie cały kontekst projektu, rozbija pracę na
małe kroki, formułuje precyzyjne zlecenia i **nigdy nie ufa bezkrytycznie**
raportowi wykonawcy.

Wykonawca (`agy` / `gemini` / `codex` — patrz `executor/config.sh`) dostaje
wąsko określone zadanie, wykonuje je i raportuje. Jest szybki i tani, ale
bywa, że zrobi coś „na pół” albo „naprawi” test, obniżając próg.

Asymetria — kierownik weryfikuje, nie tylko deleguje — jest sednem całego
setupu. Bez niej pętla po prostu przepuszcza błędy dalej.

## 2. Wywołanie wykonawcy

Zawsze przez jeden skrypt:

```bash
bash executor/run.sh <plik-zlecenia> <write|read> <plik-logu>
```

- `write` — wykonawca może zmieniać pliki; `read` — tylko odczyt (review,
  analiza, research).
- Skrypt dokleja do zlecenia `executor/rules.md` (stałe zasady) i — jeśli
  istnieje — `executor/rules.profile.md` (zasady stacku).
- Czysta odpowiedź wykonawcy ląduje w pliku logu.
- Kody wyjścia:

| Kod | Znaczenie | Co robisz |
|---|---|---|
| 0 | OK — jest odpowiedź | weryfikujesz |
| 1 | błąd / pusta odpowiedź | czytasz log; 2× z rzędu pusty log → traktuj jak 3 |
| 3 | wyczerpany limit wykonawcy | zadanie „zablokowane — limit wykonawcy”, STOP, bez commita |
| 4 | brak autoryzacji | prosisz użytkownika o zalogowanie wykonawcy w terminalu, STOP |

- Zlecenia i logi trzymaj w `.executor-logs/` (ignorowane przez git):
  `.executor-logs/<ID>-p<próba>.brief.md` i `.executor-logs/<ID>-p<próba>.log`.
- Zlecenie typu `write` uruchamiaj w tle i powiedz użytkownikowi, ile
  mniej więcej potrwa (proste: 2–5 min, większe: 10–20 min; wykonawca
  zwykle milczy do samego końca — pusty log w trakcie to nie zawieszenie).
- Przed pierwszym zleceniem w sesji: `bash executor/preflight.sh`.

## 3. Kontrakt zlecenia (brief)

Każde zlecenie ma tę strukturę. Im mniej miejsca na interpretację, tym
mniej rund pętli.

```markdown
# Zlecenie <ID> (próba <n>)

## Kontekst
Projekt: <1–2 zdania>. Przeczytaj AGENTS.md oraz: <konkretne sekcje
dokumentów, np. ARCHITECTURE.md §5, MODULES/MODULE_x.md>.

## Zadanie
<co dokładnie ma powstać / się zmienić — konkretnie>

## Pliki
- utwórz: <ścieżki>
- zmień: <ścieżki (+ funkcje/sekcje)>
- NIE ruszaj: <ścieżki, których zadanie nie dotyczy>

## Kryterium ukończenia
<mierzalne; np. „test X przechodzi”, „verify.sh exit 0”, „metryka Y ≥ Z”>

## Weryfikacja po Twojej stronie
<dokładna komenda, którą wykonawca ma uruchomić przed raportem>

## (próba > 1) Co było nie tak poprzednio
<konkretny feedback: plik, linia, zachowanie — nie ogólnikowe „popraw błędy”>
```

## 4. Pętla — algorytm

```
DLA każdego zadania z kolejki w ORCHESTRATION_STATE.md:

 1. Przeczytaj zadanie i jego kryterium ukończenia. Ustaw je jako
    „Aktualne zadanie” w ORCHESTRATION_STATE.md.
 2. Zapisz stan PRZED: `git status` (czysty), wynik `bash executor/verify.sh`
    (liczba testów, ewentualne metryki, na które zadanie może wpłynąć).
 3. Napisz zlecenie wg kontraktu (§3).
 4. Uruchom `executor/run.sh` (tryb write) i obsłuż kod wyjścia (§2).
 5. NIE UFAJ raportowi. Zweryfikuj sam (§5).
 6. Kryterium spełnione →
      - stan: zadanie → ukończone, licznik prób → 0, wpis w historii
      - jeden commit (kod + ORCHESTRATION_STATE.md + zmienione dokumenty):
        `<ID>: <opis> — via <wykonawca>, zweryfikowane` → drzewo czyste
      - następne zadanie.
 7. Kryterium NIE spełnione →
      - próba + 1, wpis w historii (co zlecono, co wyszło, co nie tak)
      - próba < 4 → konkretny feedback, wróć do 3
      - próba = 4 → „zablokowane”, pełny opis problemu w stanie, STOP.
 8. Nowy wniosek → sekcja „Lekcje” w ORCHESTRATION_STATE.md.
    Wniosek, który się powtarza → nowy punkt w executor/rules.md
    (albo rules.profile.md) + poinformuj użytkownika.
 9. Po każdym zadaniu sprawdź, czy użytkownik czegoś nie napisał.
    STOP na końcu każdego milestone'a i przy każdej blokadzie.
```

**Limit: 4 próby na zadanie.** Wystarczy na dopracowanie drobnego błędu,
a nie pozwala kręcić się w nieskończoność nad zadaniem ze źle
sformułowanym kryterium.

## 5. Weryfikacja — checklista

- [ ] `git status` / `git diff` — zmienione są tylko pliki z zakresu zlecenia.
- [ ] Przeczytane faktycznie zmienione pliki (nie tylko diffstat).
- [ ] `bash executor/verify.sh` → exit 0.
- [ ] Porównanie z PRZED: liczba testów nie zmalała; żaden próg nie został
      obniżony; żadna asercja nie zniknęła; żaden test nie został wyłączony.
- [ ] Ostrzeżenia w logach (wycieki, „still in use”, deprecated) — nie
      tylko kod wyjścia.
- [ ] Zadania z UI: uruchomienie aplikacji + zrzut ekranu (web: claude-in-chrome
      albo Playwright; sprawdź też wąski ekran/mobile). Same testy nie wystarczą.
- [ ] Zadania z wejściem (skróty, sterowanie): test prawdziwymi zdarzeniami
      wejścia z całą aplikacją.
- [ ] Zgodność z CODING_STYLE.md i GLOSSARY.md.
- [ ] Raport wykonawcy ma sekcję „Czego NIE zrobiono” — przeczytana
      i rozstrzygnięta.

## 6. Zasady bezpieczeństwa

- **Jedno zadanie = jeden commit.** Nigdy kilka zadań w jednym commicie.
- **Zablokowane zadanie nie jest commitowane** — zostaje jako `git diff`
  do przejrzenia przez użytkownika.
- Wykonawca nie robi `git` (commit/push/reset/checkout) ani operacji
  sieciowych poza pracą nad kodem. Takie rzeczy robisz Ty — albo pytasz
  użytkownika.
- Zakres jednego zlecenia **nie wykracza poza jeden moduł**. Jeśli
  zadanie z natury dotyka kilku — rozbij je.
- Każdy milestone na własnej gałęzi (`m<N>-<krótka-nazwa>`); merge do
  `main` tylko po akceptacji użytkownika.
- Nigdy nie wklejaj sekretów do zlecenia.

## 7. Koszt i tempo

- Każde zadanie kosztuje więcej niż jedno zapytanie po obu stronach —
  to cena weryfikacji. Nadal wielokrotnie taniej niż kod pisany przez
  kierownika.
- Pierwsze 1–2 milestone'y warto obserwować, zanim zaufa się pętli bardziej.
- Jeśli zauważysz, że akceptujesz zadania, które w praktyce nie działają —
  zaostrz checklistę z §5 dla danego typu zadań (dopisz tutaj).
