use actix_web::{get, App, HttpResponse, HttpServer, Responder};
use actix_web::middleware::Logger;
use dotenv;
use env_logger::Env;

#[get("/")]
async fn index() -> impl Responder {
    HttpResponse::Ok().body("Hello from rust-api!")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();
    let host: String = dotenv::var("HOST").expect("HOST must be set!");
    let port: String = dotenv::var("PORT").expect("PORT must be set!");

    let address = format!("{}:{}", host, port);

    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();

    HttpServer::new(|| {
        App::new()
            .wrap(Logger::default())
            .wrap(Logger::new("%a %{User-Agent}i"))
            .service(index)
    })
        .bind(address)?
        .run()
        .await
}