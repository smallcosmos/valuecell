"""Constants for auto trading agent"""

# Limits
MAX_SYMBOLS = 10
DEFAULT_CHECK_INTERVAL = 60  # 1 minute in seconds

# Default configuration values
DEFAULT_INITIAL_CAPITAL = 100000
DEFAULT_RISK_PER_TRADE = 0.1
DEFAULT_MAX_POSITIONS = 8

# Environment variable keys for model override
# These allow users to override specific models via environment variables
ENV_PARSER_MODEL_ID = "AUTO_TRADING_PARSER_MODEL_ID"
ENV_SIGNAL_MODEL_ID = "AUTO_TRADING_SIGNAL_MODEL_ID"
ENV_PRIMARY_MODEL_ID = "AUTO_TRADING_AGENT_MODEL_ID"

# Deprecated (kept for backward compatibility)
DEFAULT_AGENT_MODEL = "deepseek-ai/DeepSeek-V3.2-Exp"

# Setup trading with $100,000 for BNB-USD, DOGE-USI and ETH-USD using deepseek-ai/DeepSeek-V3.2-Exp, tencent/Hunyuan-MT-7B, Qwen/Qwen3-8B model

# Setup trading with $100,000 for BNB-USDT, DOGE-USDT,  ETH-USDT, ADA-USDT, SOL-USDT, XRP-USDT and DOT-USDT using deepseek-ai/DeepSeek-V3.2-Exp, tencent/Hunyuan-MT-7B, Qwen/Qwen3-8B model