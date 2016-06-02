import normalizeUrl from "normalize-url";

export default function(_message, { url }){
  window.location.href = normalizeUrl(url);
}
