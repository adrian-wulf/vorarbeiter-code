# CODING_STYLE.md — {{NAZWA}}

> Konwencje kodu Rust. Trzymaj się ich konsekwentnie — kod niezgodny
> z tym dokumentem poprawiaj przy okazji, zamiast dodawać niespójność.

<!-- kickoff: wzorzec dla Rusta. Dopasuj do odpowiedzi użytkownika. -->

## 1. Narzędzia
- `cargo fmt`, `cargo clippy -- -D warnings`.

## 2. Nazewnictwo
- snake_case dla funkcji, zmiennych, modułów; PascalCase dla typów i traitów; SCREAMING_SNAKE_CASE dla stałych.

## 3. Struktura
- Moduły według funkcji; publiczne API minimalne (`pub(crate)` domyślnie).
- Logika oddzielona od I/O; typy domenowe zamiast gołych `String`/`u64` tam, gdzie to ma znaczenie.

## 4. Błędy
- Biblioteki: własne typy błędów (`thiserror`); aplikacje: `anyhow` z kontekstem.
- Zakaz `unwrap()`/`expect()` poza testami i miejscami z udokumentowanym niezmiennikiem.
- `unsafe` tylko za zgodą użytkownika, z komentarzem `// SAFETY:`.

## 5. Komentarze
- `///` dla publicznego API; komentarz wyjaśnia **dlaczego**, nie **co**.

## 6. Testy
- Testy jednostkowe w `#[cfg(test)] mod tests`, integracyjne w `tests/`.
- Wszystko: `bash executor/verify.sh`.
