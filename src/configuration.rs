#[derive(serde::Deserialize)]
pub struct Settings {
    pub database: DatabaseSettings,
    pub application_port: u16,
}

#[derive(serde::Deserialize)]
pub struct DatabaseSettings {
    pub username: String,
    pub password: String,
    pub port: u16,
    pub host: String,
    pub database_name: String,
}

impl DatabaseSettings {
    pub fn connection_string(&self) -> String {
        format!(
            "postgres://{}:{}@{}:{}/{}",
            self.username, self.password, self.host, self.port, self.database_name
        )
    }
}

pub fn get_configuration() -> Result<Settings, config::ConfigError> {
    // init config reader
    let settings = config::Config::builder()
        .add_source(config::File::new(
            // read from configuration.yaml
            "configuration.yaml",
            config::FileFormat::Yaml,
        ))
        .build()?;
    // try to convert configuration settings into Settings type
    settings.try_deserialize::<Settings>()
}
