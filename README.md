# os specific setup
p.5

# cargo installs
cargo install cargo-watch cargo-audit
cargo install --version='~0.7' sqlx-cli --no-default-features --features rustls,postgres
# rustup installs
rustup component add clippy rustfmt
# database setup
p.55

# current page
p. 69 @ 3.8.5.5

# dependencies
## linux
- apt install pkg-config libssl-dev postgresql-client

# check if webserver alive
after running `cargo run`, run `curl -v localhost:8000/health_check`, should return 200
