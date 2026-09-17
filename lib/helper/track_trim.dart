class TrackTrim {
  static Duration clampStart(Duration proposed, Duration end) {
    if (proposed < Duration.zero) return Duration.zero;
    if (proposed > end) return end;
    return proposed;
  }

  static Duration clampEnd(Duration proposed, Duration start, Duration duration) {
    if (proposed < start) return start;
    if (proposed > duration) return duration;
    return proposed;
  }
}
