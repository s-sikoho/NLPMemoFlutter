use std::sync::OnceLock;
use tokenizers::Tokenizer;

static TOKENIZER: OnceLock<Tokenizer> = OnceLock::new();

#[derive(Debug, Clone)]
pub struct TokenizedInput {
    pub input_ids: Vec<i64>,
    pub attention_mask: Vec<i64>,
}

pub fn init_tokenizer(tokenizer_json: Vec<u8>) -> Result<(), String> {
    let tokenizer =
        Tokenizer::from_bytes(tokenizer_json)
            .map_err(|e| e.to_string())?;

    TOKENIZER
        .set(tokenizer)
        .map_err(|_| "Tokenizer is already initialized".to_string())?;

    Ok(())
}

pub fn tokenize(text: String) -> Result<TokenizedInput, String> {
    let tokenizer = TOKENIZER
        .get()
        .ok_or_else(|| "Tokenizer has not been initialized".to_string())?;

    let encoding = tokenizer
        .encode(text, true)
        .map_err(|e| e.to_string())?;

    let input_ids = encoding
        .get_ids()
        .iter()
        .map(|&id| id as i64)
        .collect();

    let attention_mask = encoding
        .get_attention_mask()
        .iter()
        .map(|&value| value as i64)
        .collect();

    Ok(TokenizedInput {
        input_ids,
        attention_mask,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tokenizer_test() {
        let bytes =
            std::fs::read("../assets/models/multilingual_e5_small/tokenizer.json")
                .unwrap();

        init_tokenizer(bytes).unwrap();

        let result =
            tokenize("query: 今日は大学に行った".to_string())
                .unwrap();

        println!("input_ids = {:?}", result.input_ids);
        println!(
            "attention_mask = {:?}",
            result.attention_mask
        );

        assert!(!result.input_ids.is_empty());
        assert_eq!(
            result.input_ids.len(),
            result.attention_mask.len()
        );
    }
}