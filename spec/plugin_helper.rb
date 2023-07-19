def remove_milliseconds_from_datetime(timestamp)
  if timestamp.is_a?(String) && timestamp.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\z/)
    DateTime.parse(timestamp).strftime('%Y-%m-%dT%H:%M:%S')
  else
    timestamp
  end
end

def conver_timestamp_to_iso_8601(timestamp)
  if timestamp.is_a?(Time)
    timestamp.utc.strftime('%Y-%m-%dT%H:%M:%S')
  else
    timestamp
  end
end

def stub_fetch_score_request(request_body, response_body)
  stub_request(:post, "https://api.scorer.gitcoin.co/registry/submit-passport").
    with(
      body: request_body,
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'Host'=>'api.scorer.gitcoin.co',
      'User-Agent'=>'Ruby',
      'X-Api-Key'=>'api-key'
      }).
    to_return(status: 200, body: response_body, headers: {})
end
