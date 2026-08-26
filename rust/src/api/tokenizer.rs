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

    Ok(TokenizedInput {
        input_ids: encoding
            .get_ids()
            .iter()
            .map(|&x| x as i64)
            .collect(),

        attention_mask: encoding
            .get_attention_mask()
            .iter()
            .map(|&x| x as i64)
            .collect(),
    })
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tokenizer_test() {
        let bytes =
            std::fs::read("../assets/models/tokenizer.json")
                .unwrap();

        init_tokenizer(bytes).unwrap();

        let result =
            tokenize("query: 今日は大学に行った".to_string())
                .unwrap();

        println!("input_ids = {:?}", result.input_ids);
        println!("attention_mask = {:?}", result.attention_mask);

        assert!(!result.input_ids.is_empty());
        assert_eq!(
            result.input_ids.len(),
            result.attention_mask.len()
        );
    }
}