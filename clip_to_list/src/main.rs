use std::io;
use std::process::Command;

fn main() -> io::Result<()> {
    let clip_text = get_clipboard()?;
    println!("CLipboard contents:\n{}", clip_text);

    let items: Vec<String> = clip_text
        .lines()
        .map(|s| s.trim())
        .filter(|s| !s.is_empty())
        .map(|s| {
            let escaped = s.replace('\'', "\\'");
            format!("'{}'", escaped)
        })
        .collect();

    let output = items.join(",");
    println!("=> {}", output);
    Ok(())
}

fn get_clipboard() -> io::Result<String> {
    let output = Command::new("wl-paste").output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}
