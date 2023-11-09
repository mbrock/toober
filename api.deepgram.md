model
string

AI model used to process submitted audio. Learn More

general
meeting
phonecall
voicemail
finance
conversationalai
video
<custom_id>
tier
string

Level of model you would like to use in your request. Learn More

enhanced
base
version
string

Version of the model to use.Learn More

latest
<version_id>
language
string

The BCP-47 language tag that hints at the primary spoken language. Learn More

da
de
en
en-AU
en-GB
en-IN
en-NZ
en-US
es
es-419
fr
fr-CA
hi
hi-Latn
id
it
ja
ko
nl
no
pl
pt
pt-BR
pt-PT
ru
sv
ta
tr
uk
zh-CN
zh-TW
punctuate
boolean

Indicates whether to add punctuation and capitalization to the transcript Learn More

true
false
profanity_filter
boolean

Indicates whether to remove profanity from the transcript. Learn More

true
false
redact
string

Indicates whether to redact sensitive information, replacing redacted content with asterisks (*). Can send multiple instances in query string (for example, redact=pci&redact=numbers). Learn More

pci
numbers
true
ssn
diarize
boolean

Indicates whether to recognize speaker changes. When set to true, each word in the transcript will be assigned a speaker number starting at 0. Learn More

true
false
diarize_version
string

Indicates the version of the diarization feature to use. Only used when the diarization feature is enabled (diarize=true is passed to the API). Learn More

smart_format
boolean

Indicates whether to apply formatting to transcript output. When set to true, additional formatting will be applied to transcripts to improve readability. Learn More

true
false
filler_words
boolean

Indicates whether to include filler words like "uh" and "um" in transcript output. When set to true, these words will be included. Defaults to false. Learn More

true
false
multichannel
boolean

Indicates whether to transcribe each audio channel independently. Learn More

true
false
alternatives
int32

Maximum number of transcript alternatives to return.

numerals
boolean

Indicates whether to convert numbers from written format (e.g., one) to numerical format (e.g., 1). Learn More

true
false
search
string

Terms or phrases to search for in the submitted audio. Can send multiple instances in query string (for example, search=speech&search=Friday). Learn More

replace
string

Terms or phrases to search for in the submitted audio and replace. Can send multiple instances in query string (for example, replace=this:that&replace=thisalso:thatalso). Learn More

callback
string

Callback URL to provide if you would like your submitted audio to be processed asynchronously. Learn More

keywords
string

Uncommon proper nouns or other words to transcribe that are not a part of the model's vocabulary. Can send multiple instances in query string (for example, keywords=snuffalupagus:10&keywords=systrom:5.5). Learn More

interim_results
string

Indicates whether the streaming endpoint should send you updates to its transcription as more audio becomes available. When set to true, the streaming endpoint returns regular updates, which means transcription results will likely change for a period of time. By default, this flag is set to false. Learn More

true
false
endpointing
string

Indicates how long Deepgram will wait to detect whether a speaker has finished speaking (or paused for a significant period of time, indicating the completion of an idea). When Deepgram detects an endpoint, it assumes that no additional data will improve its prediction, so it immediately finalizes the result for the processed time range and returns the transcript with a speech_final parameter set to true. Endpointing may be disabled by setting endpointing=false. Learn More

encoding
string

Expected encoding of the submitted streaming audio. If this parameter is set, sample_rate must also be specified. Learn More

linear16
flac
mulaw
amr-nb
amr-wb
opus
speex
channels
int32

Number of independent audio channels contained in submitted streaming audio. Only read when a value is provided for encoding. Learn More

sample_rate
int32

Sample rate of submitted streaming audio. Required (and only read) when a value is provided for encoding. Learn More

tag
string

Tag to associate with the request. Learn More