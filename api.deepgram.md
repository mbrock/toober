# Deepgram WebSocket Listen API Endpoint Specification

## Parameters

### `model`

**Type**: string  
**Description**: AI model used to process submitted audio.  
**Options**:

- general
- meeting
- phonecall
- voicemail
- finance
- conversationalai
- video
- \<custom_id\>

### `tier`

**Type**: string  
**Description**: Level of model you would like to use in your request.  
**Options**:

- enhanced
- base

### `version`

**Type**: string  
**Description**: Version of the model to use.  
**Options**:

- latest
- \<version_id\>

### `language`

**Type**: string  
**Description**: The BCP-47 language tag for the primary spoken language.  
**Options**: da, de, en, en-AU, en-GB, en-IN, en-NZ, en-US, es, es-419, fr, fr-CA, hi, hi-Latn, id, it, ja, ko, nl, no, pl, pt, pt-BR, pt-PT, ru, sv, ta, tr, uk, zh-CN, zh-TW

### `punctuate`

**Type**: boolean  
**Description**: Indicates whether to add punctuation and capitalization to the transcript.  
**Options**: true, false

### `profanity_filter`

**Type**: boolean  
**Description**: Indicates whether to remove profanity from the transcript.  
**Options**: true, false

### `redact`

**Type**: string  
**Description**: Indicates whether to redact sensitive information.  
**Options**: pci, numbers, true, ssn

### `diarize`

**Type**: boolean  
**Description**: Indicates whether to recognize speaker changes.  
**Options**: true, false

### `diarize_version`

**Type**: string  
**Description**: Version of the diarization feature. Only used when diarization is enabled.

### `smart_format`

**Type**: boolean  
**Description**: Indicates whether to apply formatting to transcript output.  
**Options**: true, false

### `filler_words`

**Type**: boolean  
**Description**: Indicates whether to include filler words in transcript output.  
**Options**: true, false

### `multichannel`

**Type**: boolean  
**Description**: Indicates whether to transcribe each audio channel independently.  
**Options**: true, false

### `alternatives`

**Type**: int32  
**Description**: Maximum number of transcript alternatives to return.

### `numerals`

**Type**: boolean  
**Description**: Indicates whether to convert numbers from written to numerical format.  
**Options**: true, false

### `search`

**Type**: string  
**Description**: Terms or phrases to search for in the submitted audio.

### `replace`

**Type**: string  
**Description**: Terms or phrases to search and replace in the submitted audio.

### `callback`

**Type**: string  
**Description**: Callback URL for asynchronous audio processing.

### `keywords`

**Type**: string  
**Description**: Uncommon words to transcribe that are not part of the model's vocabulary.

### `interim_results`

**Type**: string  
**Description**: Indicates whether to send updates to transcription as more audio becomes available.  
**Options**: true, false

### `endpointing`

**Type**: string  
**Description**: Indicates how long to wait to detect if a speaker has finished speaking.

### `encoding`

**Type**: string  
**Description**: Expected encoding of the submitted streaming audio.  
**Options**: linear16, flac, mulaw, amr-nb, amr-wb, opus, speex

### `channels`

**Type**: int32  
**Description**: Number of independent audio channels in submitted audio.

### `sample_rate`

**Type**: int32  
**Description**: Sample rate of submitted streaming audio.

### `tag`

**Type**: string  
**Description**: Tag to associate with the request.
