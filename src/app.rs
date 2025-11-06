use leptos::prelude::*;
use leptos_meta::{provide_meta_context, Link, MetaTags, Stylesheet, Title};
use leptos_router::components::{Route, Router, Routes};
use leptos_router::StaticSegment;

pub fn shell(options: LeptosOptions) -> impl IntoView {
    view! {
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <Link rel="icon" href="/favicon.ico" sizes="any"/>
                <Link rel="icon" href="/favicon.svg" sizes="any"/>
                <Link rel="apple-touch-icon" sizes="180x180" href="/icon-180x180.png"/>
                <Link rel="manifest" href="/manifest.json"/>
                <AutoReload options=options.clone() />
                <HydrationScripts options/>
                <MetaTags/>
            </head>
            <body>
                <App/>
            </body>
        </html>
    }
}

#[component]
pub fn App() -> impl IntoView {
    provide_meta_context();

    view! {
        <Stylesheet id="leptos" href="/pkg/{{project-name}}.css"/>
        <Title text="{{project-name}}"/>
        <Router>
            <main>
                <Routes fallback=|| "Page not found.".into_view()>
                    <Route path=StaticSegment("") view=HomePage/>
                </Routes>
            </main>
        </Router>
    }
}

#[component]
fn HomePage() -> impl IntoView {
    let count = RwSignal::new(0);
    let on_click = move |_| *count.write() += 1;

    view! {
        <h1 class="m-5 font-bold">"Welcome to {{project-name}}"</h1>
        <button on:click=on_click class="bg-gray-300 m-5 p-2">"Click Me: " {count}</button>
    }
}
