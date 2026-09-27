# CODING_STYLE.md — {{NAZWA}}

> Konwencje kodu Go. Trzymaj się ich konsekwentnie — kod niezgodny
> z tym dokumentem poprawiaj przy okazji, zamiast dodawać niespójność.

<!-- kickoff: wzorzec dla Go. Dopasuj do odpowiedzi użytkownika. -->

## 1. Narzędzia
- `gofmt`/`goimports`, `go vet`, `staticcheck` (lub `golangci-lint`).

## 2. Nazewnictwo
- Idiomatyczne Go: krótkie nazwy w małym zasięgu, eksportowane = PascalCase, nieeksportowane = camelCase.
- Pakiety: krótkie, małymi literami, bez podkreśleń; bez pakietów `util`/`common`.
- Interfejsy małe, definiowane po stronie konsumenta.

## 3. Struktura
- `cmd/<aplikacja>/main.go` + `internal/<moduł>/`.
- Zależności przekazywane jawnie (konstruktory), bez zmiennych globalnych.

## 4. Błędy
- Każdy błąd obsłużony albo zwrócony z kontekstem: `fmt.Errorf("zapis użytkownika: %w", err)`.
- Bez `panic` w kodzie biblioteki. `context.Context` jako pierwszy parametr operacji I/O.

## 5. Komentarze
- Komentarz dokumentacyjny dla każdego eksportowanego identyfikatora; wyjaśnia **dlaczego**, nie **co**.

## 6. Testy
- Pakiet `testing`, testy tabelaryczne, pliki `*_test.go` obok kodu; `go test -race ./...`.
- Wszystko: `bash executor/verify.sh`.
