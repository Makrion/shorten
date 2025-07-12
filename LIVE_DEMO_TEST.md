## Base URL
https://shorten.osc-fr1.scalingo.io

## Testing the functionality

1. **encode**
replace the `https://mikoool.com` with whatever link you want to shorten
   ```bash
    curl --location 'https://shorten.osc-fr1.scalingo.io/encode' \
    --header 'Content-Type: application/json' \
    --data '{"original_link": "https://mikoool.com"}'
   ```
2. **decode**
replace the `https://shorten.com/AAAAAAAMd` with the short link returned in the first encode request
   ```bash
        curl --location 'https://shorten.osc-fr1.scalingo.io/decode' \
        --header 'Content-Type: application/json' \
        --data '{"short_link": "https://shorten.com/AAAAAAAMd"}'
   ```