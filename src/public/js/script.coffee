###
 * 
 * Set settings / defaults
 * 
 * AJAX defaults
 * some constants
 * 
###
$.ajaxSetup
  type: 'POST'
usualDelay = 4000
$window = $ window 
$.fx.speeds._default = 300


# QR Code
setmask = (x, y) ->
  bt = undefined
  if x > y
    bt = x
    x = y
    y = bt
  bt = y
  bt *= y
  bt += y
  bt >>= 1
  bt += x
  framask[bt] = 1
putalign = (x, y) ->
  j = undefined
  qrframe[x + width * y] = 1
  j = -2
  while j < 2
    qrframe[(x + j) + width * (y - 2)] = 1
    qrframe[(x - 2) + width * (y + j + 1)] = 1
    qrframe[(x + 2) + width * (y + j)] = 1
    qrframe[(x + j + 1) + width * (y + 2)] = 1
    j++
  j = 0
  while j < 2
    setmask x - 1, y + j
    setmask x + 1, y - j
    setmask x - j, y - 1
    setmask x + j, y + 1
    j++
modnn = (x) ->
  while x >= 255
    x -= 255
    x = (x >> 8) + (x & 255)
  x
appendrs = (data, dlen, ecbuf, eclen) ->
  i = undefined
  j = undefined
  fb = undefined
  i = 0
  while i < eclen
    strinbuf[ecbuf + i] = 0
    i++
  i = 0
  while i < dlen
    fb = glog[strinbuf[data + i] ^ strinbuf[ecbuf]]
    unless fb is 255
      j = 1
      while j < eclen
        strinbuf[ecbuf + j - 1] = strinbuf[ecbuf + j] ^ gexp[modnn(fb + genpoly[eclen - j])]
        j++
    else
      j = ecbuf
      while j < ecbuf + eclen
        strinbuf[j] = strinbuf[j + 1]
        j++
    strinbuf[ecbuf + eclen - 1] = (if fb is 255 then 0 else gexp[modnn(fb + genpoly[0])])
    i++
ismasked = (x, y) ->
  bt = undefined
  if x > y
    bt = x
    x = y
    y = bt
  bt = y
  bt += y * y
  bt >>= 1
  bt += x
  framask[bt]
applymask = (m) ->
  x = undefined
  y = undefined
  r3x = undefined
  r3y = undefined
  switch m
    when 0
      y = 0
      while y < width
        x = 0
        while x < width
          qrframe[x + y * width] ^= 1  if not ((x + y) & 1) and not ismasked(x, y)
          x++
        y++
    when 1
      y = 0
      while y < width
        x = 0
        while x < width
          qrframe[x + y * width] ^= 1  if not (y & 1) and not ismasked(x, y)
          x++
        y++
    when 2
      y = 0
      while y < width
        r3x = 0
        x = 0

        while x < width
          r3x = 0  if r3x is 3
          qrframe[x + y * width] ^= 1  if not r3x and not ismasked(x, y)
          x++
          r3x++
        y++
    when 3
      r3y = 0
      y = 0

      while y < width
        r3y = 0  if r3y is 3
        r3x = r3y
        x = 0

        while x < width
          r3x = 0  if r3x is 3
          qrframe[x + y * width] ^= 1  if not r3x and not ismasked(x, y)
          x++
          r3x++
        y++
        r3y++
    when 4
      y = 0
      while y < width
        r3x = 0
        r3y = ((y >> 1) & 1)
        x = 0

        while x < width
          if r3x is 3
            r3x = 0
            r3y = not r3y
          qrframe[x + y * width] ^= 1  if not r3y and not ismasked(x, y)
          x++
          r3x++
        y++
    when 5
      r3y = 0
      y = 0

      while y < width
        r3y = 0  if r3y is 3
        r3x = 0
        x = 0

        while x < width
          r3x = 0  if r3x is 3
          qrframe[x + y * width] ^= 1  if not (x & y & 1) + not (not r3x | not r3y) and not ismasked(x, y)
          x++
          r3x++
        y++
        r3y++
    when 6
      r3y = 0
      y = 0

      while y < width
        r3y = 0  if r3y is 3
        r3x = 0
        x = 0

        while x < width
          r3x = 0  if r3x is 3
          qrframe[x + y * width] ^= 1  if not ((x & y & 1) + (r3x and (r3x is r3y)) & 1) and not ismasked(x, y)
          x++
          r3x++
        y++
        r3y++
    when 7
      r3y = 0
      y = 0

      while y < width
        r3y = 0  if r3y is 3
        r3x = 0
        x = 0

        while x < width
          r3x = 0  if r3x is 3
          qrframe[x + y * width] ^= 1  if not ((r3x and (r3x is r3y)) + ((x + y) & 1) & 1) and not ismasked(x, y)
          x++
          r3x++
        y++
        r3y++
  return
badruns = (length) ->
  i = undefined
  runsbad = 0
  i = 0
  while i <= length
    runsbad += N1 + rlens[i] - 5  if rlens[i] >= 5
    i++
  i = 3
  while i < length - 1
    runsbad += N3  if rlens[i - 2] is rlens[i + 2] and rlens[i + 2] is rlens[i - 1] and rlens[i - 1] is rlens[i + 1] and rlens[i - 1] * 3 is rlens[i] and (rlens[i - 3] is 0 or i + 3 > length or rlens[i - 3] * 3 >= rlens[i] * 4 or rlens[i + 3] * 3 >= rlens[i] * 4)
    i += 2
  runsbad
badcheck = ->
  x = undefined
  y = undefined
  h = undefined
  b = undefined
  b1 = undefined
  thisbad = 0
  bw = 0
  y = 0
  while y < width - 1
    x = 0
    while x < width - 1
      thisbad += N2  if (qrframe[x + width * y] and qrframe[(x + 1) + width * y] and qrframe[x + width * (y + 1)] and qrframe[(x + 1) + width * (y + 1)]) or not (qrframe[x + width * y] or qrframe[(x + 1) + width * y] or qrframe[x + width * (y + 1)] or qrframe[(x + 1) + width * (y + 1)])
      x++
    y++
  y = 0
  while y < width
    rlens[0] = 0
    h = b = x = 0
    while x < width
      if (b1 = qrframe[x + width * y]) is b
        rlens[h]++
      else
        rlens[++h] = 1
      b = b1
      bw += (if b then 1 else -1)
      x++
    thisbad += badruns(h)
    y++
  bw = -bw  if bw < 0
  big = bw
  count = 0
  big += big << 2
  big <<= 1
  while big > width * width
    big -= width * width
    count++
  thisbad += count * N4
  x = 0
  while x < width
    rlens[0] = 0
    h = b = y = 0
    while y < width
      if (b1 = qrframe[x + width * y]) is b
        rlens[h]++
      else
        rlens[++h] = 1
      b = b1
      y++
    thisbad += badruns(h)
    x++
  thisbad
genframe = (instring) ->
  x = undefined
  y = undefined
  k = undefined
  t = undefined
  v = undefined
  i = undefined
  j = undefined
  m = undefined
  t = instring.length
  version = 0
  loop
    version++
    k = (ecclevel - 1) * 4 + (version - 1) * 16
    neccblk1 = eccblocks[k++]
    neccblk2 = eccblocks[k++]
    datablkw = eccblocks[k++]
    eccblkwid = eccblocks[k]
    k = datablkw * (neccblk1 + neccblk2) + neccblk2 - 3 + (version <= 9)
    break  if t <= k
    break unless version < 40
  width = 17 + 4 * version
  v = datablkw + (datablkw + eccblkwid) * (neccblk1 + neccblk2) + neccblk2
  t = 0
  while t < v
    eccbuf[t] = 0
    t++
  strinbuf = instring.slice(0)
  t = 0
  while t < width * width
    qrframe[t] = 0
    t++
  t = 0
  while t < (width * (width + 1) + 1) / 2
    framask[t] = 0
    t++
  t = 0
  while t < 3
    k = 0
    y = 0
    k = (width - 7)  if t is 1
    y = (width - 7)  if t is 2
    qrframe[(y + 3) + width * (k + 3)] = 1
    x = 0
    while x < 6
      qrframe[(y + x) + width * k] = 1
      qrframe[y + width * (k + x + 1)] = 1
      qrframe[(y + 6) + width * (k + x)] = 1
      qrframe[(y + x + 1) + width * (k + 6)] = 1
      x++
    x = 1
    while x < 5
      setmask y + x, k + 1
      setmask y + 1, k + x + 1
      setmask y + 5, k + x
      setmask y + x + 1, k + 5
      x++
    x = 2
    while x < 4
      qrframe[(y + x) + width * (k + 2)] = 1
      qrframe[(y + 2) + width * (k + x + 1)] = 1
      qrframe[(y + 4) + width * (k + x)] = 1
      qrframe[(y + x + 1) + width * (k + 4)] = 1
      x++
    t++
  if version > 1
    t = adelta[version]
    y = width - 7
    loop
      x = width - 7
      while x > t - 3
        putalign x, y
        break  if x < t
        x -= t
      break  if y <= t + 9
      y -= t
      putalign 6, y
      putalign y, 6
  qrframe[8 + width * (width - 8)] = 1
  y = 0
  while y < 7
    setmask 7, y
    setmask width - 8, y
    setmask 7, y + width - 7
    y++
  x = 0
  while x < 8
    setmask x, 7
    setmask x + width - 8, 7
    setmask x, width - 8
    x++
  x = 0
  while x < 9
    setmask x, 8
    x++
  x = 0
  while x < 8
    setmask x + width - 8, 8
    setmask 8, x
    x++
  y = 0
  while y < 7
    setmask 8, y + width - 7
    y++
  x = 0
  while x < width - 14
    if x & 1
      setmask 8 + x, 6
      setmask 6, 8 + x
    else
      qrframe[(8 + x) + width * 6] = 1
      qrframe[6 + width * (8 + x)] = 1
    x++
  if version > 6
    t = vpat[version - 7]
    k = 17
    x = 0
    while x < 6
      y = 0
      while y < 3
        if 1 & (if k > 11 then version >> (k - 12) else t >> k)
          qrframe[(5 - x) + width * (2 - y + width - 11)] = 1
          qrframe[(2 - y + width - 11) + width * (5 - x)] = 1
        else
          setmask 5 - x, 2 - y + width - 11
          setmask 2 - y + width - 11, 5 - x
        y++
        k--
      x++
  y = 0
  while y < width
    x = 0
    while x <= y
      setmask x, y  if qrframe[x + width * y]
      x++
    y++
  v = strinbuf.length
  i = 0
  while i < v
    eccbuf[i] = strinbuf.charCodeAt(i)
    i++
  strinbuf = eccbuf.slice(0)
  x = datablkw * (neccblk1 + neccblk2) + neccblk2
  if v >= x - 2
    v = x - 2
    v--  if version > 9
  i = v
  if version > 9
    strinbuf[i + 2] = 0
    strinbuf[i + 3] = 0
    while i--
      t = strinbuf[i]
      strinbuf[i + 3] |= 255 & (t << 4)
      strinbuf[i + 2] = t >> 4
    strinbuf[2] |= 255 & (v << 4)
    strinbuf[1] = v >> 4
    strinbuf[0] = 0x40 | (v >> 12)
  else
    strinbuf[i + 1] = 0
    strinbuf[i + 2] = 0
    while i--
      t = strinbuf[i]
      strinbuf[i + 2] |= 255 & (t << 4)
      strinbuf[i + 1] = t >> 4
    strinbuf[1] |= 255 & (v << 4)
    strinbuf[0] = 0x40 | (v >> 4)
  i = v + 3 - (version < 10)
  while i < x
    strinbuf[i++] = 0xec
    strinbuf[i++] = 0x11
  genpoly[0] = 1
  i = 0
  while i < eccblkwid
    genpoly[i + 1] = 1
    j = i
    while j > 0
      genpoly[j] = (if genpoly[j] then genpoly[j - 1] ^ gexp[modnn(glog[genpoly[j]] + i)] else genpoly[j - 1])
      j--
    genpoly[0] = gexp[modnn(glog[genpoly[0]] + i)]
    i++
  i = 0
  while i <= eccblkwid
    genpoly[i] = glog[genpoly[i]]
    i++
  k = x
  y = 0
  i = 0
  while i < neccblk1
    appendrs y, datablkw, k, eccblkwid
    y += datablkw
    k += eccblkwid
    i++
  i = 0
  while i < neccblk2
    appendrs y, datablkw + 1, k, eccblkwid
    y += datablkw + 1
    k += eccblkwid
    i++
  y = 0
  i = 0
  while i < datablkw
    j = 0
    while j < neccblk1
      eccbuf[y++] = strinbuf[i + j * datablkw]
      j++
    j = 0
    while j < neccblk2
      eccbuf[y++] = strinbuf[(neccblk1 * datablkw) + i + (j * (datablkw + 1))]
      j++
    i++
  j = 0
  while j < neccblk2
    eccbuf[y++] = strinbuf[(neccblk1 * datablkw) + i + (j * (datablkw + 1))]
    j++
  i = 0
  while i < eccblkwid
    j = 0
    while j < neccblk1 + neccblk2
      eccbuf[y++] = strinbuf[x + i + j * eccblkwid]
      j++
    i++
  strinbuf = eccbuf
  x = y = width - 1
  k = v = 1
  m = (datablkw + eccblkwid) * (neccblk1 + neccblk2) + neccblk2
  i = 0
  while i < m
    t = strinbuf[i]
    j = 0
    while j < 8
      qrframe[x + width * y] = 1  if 0x80 & t
      loop
        unless v
          x++
          if k
            if y is 0
              x -= 2
              k = not k
              if x is 6
                x--
                y = 9
          else
            if y is width - 1
              x -= 2
              k = not k
              if x is 6
                x--
                y -= 8
        v = not v
        break unless ismasked(x, y)
      j++
      t <<= 1
    i++
  strinbuf = qrframe.slice(0)
  t = 0
  y = 30000
  k = 0
  while k < 8
    applymask k
    x = badcheck()
    if x < y
      y = x
      t = k
    break  if t is 7
    qrframe = strinbuf.slice(0)
    k++
  applymask t  unless t is k
  y = fmtword[t + ((ecclevel - 1) << 3)]
  k = 0
  while k < 8
    if y & 1
      qrframe[(width - 1 - k) + width * 8] = 1
      if k < 6
        qrframe[8 + width * k] = 1
      else
        qrframe[8 + width * (k + 1)] = 1
    k++
    y >>= 1
  k = 0
  while k < 7
    if y & 1
      qrframe[8 + width * (width - 7 + k)] = 1
      if k
        qrframe[(6 - k) + width * 8] = 1
      else
        qrframe[7 + width * 8] = 1
    k++
    y >>= 1
  qrframe
adelta = [ 0, 11, 15, 19, 23, 27, 31, 16, 18, 20, 22, 24, 26, 28, 20, 22, 24, 24, 26, 28, 28, 22, 24, 24, 26, 26, 28, 28, 24, 24, 26, 26, 26, 28, 28, 24, 26, 26, 26, 28, 28 ]
vpat = [ 0xc94, 0x5bc, 0xa99, 0x4d3, 0xbf6, 0x762, 0x847, 0x60d, 0x928, 0xb78, 0x45d, 0xa17, 0x532, 0x9a6, 0x683, 0x8c9, 0x7ec, 0xec4, 0x1e1, 0xfab, 0x08e, 0xc1a, 0x33f, 0xd75, 0x250, 0x9d5, 0x6f0, 0x8ba, 0x79f, 0xb0b, 0x42e, 0xa64, 0x541, 0xc69 ]
fmtword = [ 0x77c4, 0x72f3, 0x7daa, 0x789d, 0x662f, 0x6318, 0x6c41, 0x6976, 0x5412, 0x5125, 0x5e7c, 0x5b4b, 0x45f9, 0x40ce, 0x4f97, 0x4aa0, 0x355f, 0x3068, 0x3f31, 0x3a06, 0x24b4, 0x2183, 0x2eda, 0x2bed, 0x1689, 0x13be, 0x1ce7, 0x19d0, 0x0762, 0x0255, 0x0d0c, 0x083b ]
eccblocks = [ 1, 0, 19, 7, 1, 0, 16, 10, 1, 0, 13, 13, 1, 0, 9, 17, 1, 0, 34, 10, 1, 0, 28, 16, 1, 0, 22, 22, 1, 0, 16, 28, 1, 0, 55, 15, 1, 0, 44, 26, 2, 0, 17, 18, 2, 0, 13, 22, 1, 0, 80, 20, 2, 0, 32, 18, 2, 0, 24, 26, 4, 0, 9, 16, 1, 0, 108, 26, 2, 0, 43, 24, 2, 2, 15, 18, 2, 2, 11, 22, 2, 0, 68, 18, 4, 0, 27, 16, 4, 0, 19, 24, 4, 0, 15, 28, 2, 0, 78, 20, 4, 0, 31, 18, 2, 4, 14, 18, 4, 1, 13, 26, 2, 0, 97, 24, 2, 2, 38, 22, 4, 2, 18, 22, 4, 2, 14, 26, 2, 0, 116, 30, 3, 2, 36, 22, 4, 4, 16, 20, 4, 4, 12, 24, 2, 2, 68, 18, 4, 1, 43, 26, 6, 2, 19, 24, 6, 2, 15, 28, 4, 0, 81, 20, 1, 4, 50, 30, 4, 4, 22, 28, 3, 8, 12, 24, 2, 2, 92, 24, 6, 2, 36, 22, 4, 6, 20, 26, 7, 4, 14, 28, 4, 0, 107, 26, 8, 1, 37, 22, 8, 4, 20, 24, 12, 4, 11, 22, 3, 1, 115, 30, 4, 5, 40, 24, 11, 5, 16, 20, 11, 5, 12, 24, 5, 1, 87, 22, 5, 5, 41, 24, 5, 7, 24, 30, 11, 7, 12, 24, 5, 1, 98, 24, 7, 3, 45, 28, 15, 2, 19, 24, 3, 13, 15, 30, 1, 5, 107, 28, 10, 1, 46, 28, 1, 15, 22, 28, 2, 17, 14, 28, 5, 1, 120, 30, 9, 4, 43, 26, 17, 1, 22, 28, 2, 19, 14, 28, 3, 4, 113, 28, 3, 11, 44, 26, 17, 4, 21, 26, 9, 16, 13, 26, 3, 5, 107, 28, 3, 13, 41, 26, 15, 5, 24, 30, 15, 10, 15, 28, 4, 4, 116, 28, 17, 0, 42, 26, 17, 6, 22, 28, 19, 6, 16, 30, 2, 7, 111, 28, 17, 0, 46, 28, 7, 16, 24, 30, 34, 0, 13, 24, 4, 5, 121, 30, 4, 14, 47, 28, 11, 14, 24, 30, 16, 14, 15, 30, 6, 4, 117, 30, 6, 14, 45, 28, 11, 16, 24, 30, 30, 2, 16, 30, 8, 4, 106, 26, 8, 13, 47, 28, 7, 22, 24, 30, 22, 13, 15, 30, 10, 2, 114, 28, 19, 4, 46, 28, 28, 6, 22, 28, 33, 4, 16, 30, 8, 4, 122, 30, 22, 3, 45, 28, 8, 26, 23, 30, 12, 28, 15, 30, 3, 10, 117, 30, 3, 23, 45, 28, 4, 31, 24, 30, 11, 31, 15, 30, 7, 7, 116, 30, 21, 7, 45, 28, 1, 37, 23, 30, 19, 26, 15, 30, 5, 10, 115, 30, 19, 10, 47, 28, 15, 25, 24, 30, 23, 25, 15, 30, 13, 3, 115, 30, 2, 29, 46, 28, 42, 1, 24, 30, 23, 28, 15, 30, 17, 0, 115, 30, 10, 23, 46, 28, 10, 35, 24, 30, 19, 35, 15, 30, 17, 1, 115, 30, 14, 21, 46, 28, 29, 19, 24, 30, 11, 46, 15, 30, 13, 6, 115, 30, 14, 23, 46, 28, 44, 7, 24, 30, 59, 1, 16, 30, 12, 7, 121, 30, 12, 26, 47, 28, 39, 14, 24, 30, 22, 41, 15, 30, 6, 14, 121, 30, 6, 34, 47, 28, 46, 10, 24, 30, 2, 64, 15, 30, 17, 4, 122, 30, 29, 14, 46, 28, 49, 10, 24, 30, 24, 46, 15, 30, 4, 18, 122, 30, 13, 32, 46, 28, 48, 14, 24, 30, 42, 32, 15, 30, 20, 4, 117, 30, 40, 7, 47, 28, 43, 22, 24, 30, 10, 67, 15, 30, 19, 6, 118, 30, 18, 31, 47, 28, 34, 34, 24, 30, 20, 61, 15, 30 ]
glog = [ 0xff, 0x00, 0x01, 0x19, 0x02, 0x32, 0x1a, 0xc6, 0x03, 0xdf, 0x33, 0xee, 0x1b, 0x68, 0xc7, 0x4b, 0x04, 0x64, 0xe0, 0x0e, 0x34, 0x8d, 0xef, 0x81, 0x1c, 0xc1, 0x69, 0xf8, 0xc8, 0x08, 0x4c, 0x71, 0x05, 0x8a, 0x65, 0x2f, 0xe1, 0x24, 0x0f, 0x21, 0x35, 0x93, 0x8e, 0xda, 0xf0, 0x12, 0x82, 0x45, 0x1d, 0xb5, 0xc2, 0x7d, 0x6a, 0x27, 0xf9, 0xb9, 0xc9, 0x9a, 0x09, 0x78, 0x4d, 0xe4, 0x72, 0xa6, 0x06, 0xbf, 0x8b, 0x62, 0x66, 0xdd, 0x30, 0xfd, 0xe2, 0x98, 0x25, 0xb3, 0x10, 0x91, 0x22, 0x88, 0x36, 0xd0, 0x94, 0xce, 0x8f, 0x96, 0xdb, 0xbd, 0xf1, 0xd2, 0x13, 0x5c, 0x83, 0x38, 0x46, 0x40, 0x1e, 0x42, 0xb6, 0xa3, 0xc3, 0x48, 0x7e, 0x6e, 0x6b, 0x3a, 0x28, 0x54, 0xfa, 0x85, 0xba, 0x3d, 0xca, 0x5e, 0x9b, 0x9f, 0x0a, 0x15, 0x79, 0x2b, 0x4e, 0xd4, 0xe5, 0xac, 0x73, 0xf3, 0xa7, 0x57, 0x07, 0x70, 0xc0, 0xf7, 0x8c, 0x80, 0x63, 0x0d, 0x67, 0x4a, 0xde, 0xed, 0x31, 0xc5, 0xfe, 0x18, 0xe3, 0xa5, 0x99, 0x77, 0x26, 0xb8, 0xb4, 0x7c, 0x11, 0x44, 0x92, 0xd9, 0x23, 0x20, 0x89, 0x2e, 0x37, 0x3f, 0xd1, 0x5b, 0x95, 0xbc, 0xcf, 0xcd, 0x90, 0x87, 0x97, 0xb2, 0xdc, 0xfc, 0xbe, 0x61, 0xf2, 0x56, 0xd3, 0xab, 0x14, 0x2a, 0x5d, 0x9e, 0x84, 0x3c, 0x39, 0x53, 0x47, 0x6d, 0x41, 0xa2, 0x1f, 0x2d, 0x43, 0xd8, 0xb7, 0x7b, 0xa4, 0x76, 0xc4, 0x17, 0x49, 0xec, 0x7f, 0x0c, 0x6f, 0xf6, 0x6c, 0xa1, 0x3b, 0x52, 0x29, 0x9d, 0x55, 0xaa, 0xfb, 0x60, 0x86, 0xb1, 0xbb, 0xcc, 0x3e, 0x5a, 0xcb, 0x59, 0x5f, 0xb0, 0x9c, 0xa9, 0xa0, 0x51, 0x0b, 0xf5, 0x16, 0xeb, 0x7a, 0x75, 0x2c, 0xd7, 0x4f, 0xae, 0xd5, 0xe9, 0xe6, 0xe7, 0xad, 0xe8, 0x74, 0xd6, 0xf4, 0xea, 0xa8, 0x50, 0x58, 0xaf ]
gexp = [ 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1d, 0x3a, 0x74, 0xe8, 0xcd, 0x87, 0x13, 0x26, 0x4c, 0x98, 0x2d, 0x5a, 0xb4, 0x75, 0xea, 0xc9, 0x8f, 0x03, 0x06, 0x0c, 0x18, 0x30, 0x60, 0xc0, 0x9d, 0x27, 0x4e, 0x9c, 0x25, 0x4a, 0x94, 0x35, 0x6a, 0xd4, 0xb5, 0x77, 0xee, 0xc1, 0x9f, 0x23, 0x46, 0x8c, 0x05, 0x0a, 0x14, 0x28, 0x50, 0xa0, 0x5d, 0xba, 0x69, 0xd2, 0xb9, 0x6f, 0xde, 0xa1, 0x5f, 0xbe, 0x61, 0xc2, 0x99, 0x2f, 0x5e, 0xbc, 0x65, 0xca, 0x89, 0x0f, 0x1e, 0x3c, 0x78, 0xf0, 0xfd, 0xe7, 0xd3, 0xbb, 0x6b, 0xd6, 0xb1, 0x7f, 0xfe, 0xe1, 0xdf, 0xa3, 0x5b, 0xb6, 0x71, 0xe2, 0xd9, 0xaf, 0x43, 0x86, 0x11, 0x22, 0x44, 0x88, 0x0d, 0x1a, 0x34, 0x68, 0xd0, 0xbd, 0x67, 0xce, 0x81, 0x1f, 0x3e, 0x7c, 0xf8, 0xed, 0xc7, 0x93, 0x3b, 0x76, 0xec, 0xc5, 0x97, 0x33, 0x66, 0xcc, 0x85, 0x17, 0x2e, 0x5c, 0xb8, 0x6d, 0xda, 0xa9, 0x4f, 0x9e, 0x21, 0x42, 0x84, 0x15, 0x2a, 0x54, 0xa8, 0x4d, 0x9a, 0x29, 0x52, 0xa4, 0x55, 0xaa, 0x49, 0x92, 0x39, 0x72, 0xe4, 0xd5, 0xb7, 0x73, 0xe6, 0xd1, 0xbf, 0x63, 0xc6, 0x91, 0x3f, 0x7e, 0xfc, 0xe5, 0xd7, 0xb3, 0x7b, 0xf6, 0xf1, 0xff, 0xe3, 0xdb, 0xab, 0x4b, 0x96, 0x31, 0x62, 0xc4, 0x95, 0x37, 0x6e, 0xdc, 0xa5, 0x57, 0xae, 0x41, 0x82, 0x19, 0x32, 0x64, 0xc8, 0x8d, 0x07, 0x0e, 0x1c, 0x38, 0x70, 0xe0, 0xdd, 0xa7, 0x53, 0xa6, 0x51, 0xa2, 0x59, 0xb2, 0x79, 0xf2, 0xf9, 0xef, 0xc3, 0x9b, 0x2b, 0x56, 0xac, 0x45, 0x8a, 0x09, 0x12, 0x24, 0x48, 0x90, 0x3d, 0x7a, 0xf4, 0xf5, 0xf7, 0xf3, 0xfb, 0xeb, 0xcb, 0x8b, 0x0b, 0x16, 0x2c, 0x58, 0xb0, 0x7d, 0xfa, 0xe9, 0xcf, 0x83, 0x1b, 0x36, 0x6c, 0xd8, 0xad, 0x47, 0x8e, 0x00 ]
strinbuf = []
eccbuf = []
qrframe = []
framask = []
rlens = []
version = undefined
width = undefined
neccblk1 = undefined
neccblk2 = undefined
datablkw = undefined
eccblkwid = undefined
ecclevel = 1
genpoly = []
N1 = 3
N2 = 3
N3 = 40
N4 = 10
wd = undefined
ht = undefined
qrc = undefined

###
 * 
 * Modal Handling Functions
 * 
 * show tooltip, can be used on any element with jquery
 * 
 * 
###
$.fn.showTooltip = (options) ->
  settings = 
    position: 'below'
  this.each (i) ->
    if options
      $.extend settings, options

    $t = $(this)
    offset = $t.offset()
    data = $t.data 'tooltips'
    if !data
      data = []
    if settings.message
      tooltip = $('<div class="tooltip" />')
      tooltip.html settings.message
      tooltip.css
        left: offset.left
        top: offset.top + ( if settings.position=='below' then $t.height()+40 else 0 )
      $('body').append tooltip
      for i in data
        i.stop(true,true).fadeOut()
      data.push tooltip
      if data.length > 5
        toRemove = data.shift()
        toRemove.remove()
      $t.data 'tooltips', data
    else
      tooltip = data[data.length-1]
    ###

        TODO : Make the animation in a custom slide up / slide down thing with $.animate

    ###
    tooltip.stop(true,true).fadeIn().delay(usualDelay).fadeOut()

###
   * 
   * Modal Handling Functions
   * 
   * Basic load
   * 
   * 
###
loadModal = (options, next) ->

  scrollbarWidth = $.scrollbarWidth()
  modal = $('<div class="modal" />')
  win = $('<div class="window" />')
  close = $('<div class="close" />')

  settings =
    width: 500
    height: 235
    closeText: 'close'

  if options
    $.extend settings, options


  myNext = () ->
    $window.unbind 'scroll resize',resizeEvent
    $window.unbind 'resize',resizeEvent
    $body.css
      overflow:'inherit'
      'padding-right':0
    modal.fadeOut () -> modal.remove()
    close.fadeOut () -> close.remove()
    win.fadeOut () ->
      win.remove()
      if($('.window').length==0)
        $('#container').show()

  if settings.closeText
    close.html settings.closeText
  if settings.content
    win.html settings.content
  if settings.height
    win.css
      'min-height':settings.height
  if settings.width
    win.width settings.width

  buttons = $ '<div class="buttons" />'

  ###
  Loop through the buttons passed in.

  Buttons will be passed in as an array of objects. Each object with label string and action function

  settings.buttons = [
    {
      label: 'Button 1'
      action: function(){ alert('Button 1 clicked')}
    },
    {
      label: 'Button 2'
      action: function(){ alert('Button 2 clicked')}
    }
  ]
  ###
  if settings.buttons
    for i in settings.buttons
      thisButton = $ '<input type="button" class="button" value="'+i.label+'" class="submit">'
      if i.class
        thisButton.addClass i.class
      else
        thisButton.addClass 'normal'
      thisButton.click () ->
        i.action myNext
      buttons.append thisButton

  win.append buttons

  $('body').append modal,close,win


  $body = $('body')
  resizeEvent = () ->
    width = $window.width()
    height = $window.height()
    if width < settings.width || height < win.height()
      $window.unbind 'scroll resize',resizeEvent
      close.css
        position:'relative'
      win.width(width-60).css
        position:'relative'
      $('#container').hide()
      top = close.offset().top
      modal.css
        top:0
        left:0
        width:width
        height:top
      window.scroll 0,top
    else
      $body.css
        overflow:'hidden'
        'padding-right':scrollbarWidth
      win.position
        of:$window
        at:'center center'
        my:'center center'
        offset:'0 40px'
      modal.position
        of:$window
        at:'center center'
      close.position
        of:win
        at:'right top'
        my:'right bottom'
        offset:'0 0'

  $window.bind 'resize scroll', resizeEvent

  modal.click myNext
  close.click myNext
  width = $window.width()
  height = $window.height()
  if width < settings.width || height < win.height()
    modal.show()
    win.show()
    close.show()
  else
    modal.fadeIn()
    win.fadeIn()
    close.fadeIn()

  if next
    next myNext
  resizeEvent()

###
 * 
 * Modal Handling Functions
 * 
 * Load Loading (Subclass of loadmodal)
 * 
 * 
###
loadLoading = (options, next) ->
  options = options || {}
  modifiedOptions =
    content: 'Loading ... '
    height: 100
    width: 200

  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Confirm (Subclass of loadmodal)
 * like javascript confirm()
 * 
###
loadConfirm = (options, next) ->
  options = options || {}
  modifiedOptions =
    content: 'Confirm'
    height: 80
    width: 300
  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Alert (Subclass of loadmodal)
 * like javascript alert()
 * 
###
loadAlert = (options, next) ->
  options = options || {}
  next = next || () ->
  if typeof(options) == 'string'
    options = 
      content:options
  modifiedOptions =
    content: 'Alert'
    buttons: [
      action: (close) -> close()
      label: 'Ok'
    ]
    height: 80
    width: 300
  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next


###
 * jQuery Scrollbar Width v1.0
 * 
 * Copyright 2011, Rasmus Schultz
 * Licensed under LGPL v3.0
 * http:#www.gnu.org/licenses/lgpl-3.0.txt
###
$.scrollbarWidth = () ->
  if !$._scrollbarWidth
    $body = $ 'body'
    w = $body.css('overflow', 'hidden').width()
    $body.css('overflow','scroll')
    w -= $body.width()
    if !w
      w = $body.width() - $body[0].clientWidth
    $body.css 'overflow',''
    $._scrollbarWidth = w
  $._scrollbarWidth


###
#http:#stevenlevithan.com/assets/misc/date.format.js
 * Date Format 1.2.3
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
###

class dateFormat

  token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g
  timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g
  timezoneClip = /[^-+\dA-Z]/g
  pad = (val, len) ->
    val = String(val)
    len = len || 2
    while val.length < len
      val = "0" + val
    val

  format: (date, mask, utc) ->
    dF = dateFormat.prototype

    # You can't provide utc if you skip other args (use the "UTC:" mask prefix)
    if arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)
      mask = date
      date = undefined

    # Passing date through Date applies Date.parse, if necessary
    date = if date then new Date(date) else new Date
    if isNaN(date) 
      throw SyntaxError "invalid date"

    mask = String dF.masks[mask] || mask || dF.masks["default"]

    # Allow setting the utc argument via the mask
    if mask.slice(0, 4) == "UTC:"
      mask = mask.slice(4)
      utc = true

    _ = if utc then "getUTC" else "get"
    d = date[_ + "Date"]()
    D = date[_ + "Day"]()
    m = date[_ + "Month"]()
    y = date[_ + "FullYear"]()
    H = date[_ + "Hours"]()
    M = date[_ + "Minutes"]()
    s = date[_ + "Seconds"]()
    L = date[_ + "Milliseconds"]()
    o = utc ? 0 : date.getTimezoneOffset()
    flags =
      d:    d
      dd:   pad d
      ddd:  dF.i18n.dayNames[D]
      dddd: dF.i18n.dayNames[D + 7]
      m:    m + 1
      mm:   pad m + 1
      mmm:  dF.i18n.monthNames[m]
      mmmm: dF.i18n.monthNames[m + 12]
      yy:   String(y).slice 2
      yyyy: y
      h:    H % 12 || 12
      hh:   pad H % 12 || 12
      H:    H
      HH:   pad H
      M:    M
      MM:   pad M
      s:    s
      ss:   pad s
      l:    pad L, 3
      L:    pad if L > 99 then Math.round L / 10 else L
      t:    if H < 12 then "a"  else "p"
      tt:   if H < 12 then "am" else "pm"
      T:    if H < 12 then "A"  else "P"
      TT:   if H < 12 then "AM" else "PM"
      Z:    if utc then "UTC" else (String(date).match(timezone) || [""]).pop().replace(timezoneClip, "")
      o:    (if o > 0 then "-" else "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
      S:    ["th", "st", "nd", "rd"][if d % 10 > 3 then 0 else (d % 100 - d % 10 != 10) * d % 10]


    mask.replace token, ($0) ->
      if flags then flags[$0] else $0.slice(1, $0.length - 1)

  # Some common format strings
  masks :
    default:      "ddd mmm dd yyyy HH:MM:ss"
    shortDate:      "m/d/yy"
    mediumDate:     "mmm d, yyyy"
    longDate:       "mmmm d, yyyy"
    fullDate:       "dddd, mmmm d, yyyy"
    shortTime:      "h:MM TT"
    mediumTime:     "h:MM:ss TT"
    longTime:       "h:MM:ss TT Z"
    isoDate:        "yyyy-mm-dd"
    isoTime:        "HH:MM:ss"
    isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss"
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"


  # Internationalization strings
  i18n :
    dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


# For convenience...
Date::format = (mask, utc) ->
  a = new dateFormat
  a.format(this, mask, utc)


###
 * jQuery Cookie plugin
 *
 * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
###
jQuery.cookie = (key, value, options) ->

  # key and at least value given, set cookie...
  if arguments.length > 1 && String(value) != "[object Object]"
    options = jQuery.extend {}, options
    if value == null || value == undefined
      options.expires = -1
    if typeof options.expires == 'number'
      days = options.expires
      t = options.expires = new Date()
      t.setDate t.getDate() + days

    value = String value

    document.cookie = [
      encodeURIComponent(key), '=',
      if options.raw then value else encodeURIComponent(value),
      if options.expires then '; expires=' + options.expires.toUTCString() else '', # use expires attribute, max-age is not supported by IE
      if options.path then '; path=' + options.path else 'path=/',
      if options.domain then '; domain=' + options.domain else '',
      if options.secure then '; secure' else ''
    ].join('')

  # key and possibly options given, get cookie...
  options = value || {}
  decode =  if options.raw  then (s) ->  s  else decodeURIComponent
  if (result = new RegExp('(?:^| )' + encodeURIComponent(key) + '=([^]*)').exec(document.cookie)) then decode(result[1]) else null


# Box rotate anything you want a lil bit
$.fn.box_rotate = (options) ->
  settings = 
    position: 'below'
  this.each (i) ->
    if options
      $.extend settings, options

    $t = $(this)
    degrees = settings.degrees
    rotate = Math.floor( (degrees/360)*100 )/100
    $t.css
      '-moz-transform':'rotate('+degrees+'deg)'
      '-webkit-transform':'rotate('+degrees+'deg)'
      '-o-transform':'rotate('+degrees+'deg)'
      '-ms-transform':'rotate('+degrees+'deg)'
      'filter:progid':'DXImageTransform.Microsoft.BasicImage(rotation='+rotate+')'




###


THIS IS WHERE REAL CODE STARTS

The 
$ ->

  Means everything under him (like me, indented here)
  WILL be done on document ready event.



###

$ ->



  ###
  Profile MENU in the TOP RIGHT
  Thing that shows a drop down
  ###
  $a = $ '.account-link'
  $am = $a.find '.account-menu'
  $body = $(document)
  $('.small-nav li').hover ->
    $(this).addClass 'hover'
  , ->
    $(this).removeClass 'hover'
  closeMenu = (e) ->
    $t = $ e.target
    if $t.closest('.account-link').length
      $a = $t.closest('li').find 'a'
      document.location.href = $a.attr 'href'
    else
      $a.removeClass 'click'
      $am.slideUp()
      $a.one 'click', expandMenu
      $body.unbind 'click', closeMenu
    false
  expandMenu = ->
    $am.slideDown()
    $a.addClass 'click'
    $body.bind 'click', closeMenu
    false
  $a.one 'click', expandMenu




  # One Line Comment

  ###
  Multiple
  Lines Of
  Comments
  ###





  # Path we'll use a few places, it's just the page we're on now, yeah?
  path = document.location.href.replace /http:\/\/[^\/]*/ig, ''

  #
  # Get Started Button Scroll
  $('.design-button').click ->
    if path != '/'
      document.location.href = '/#design-button'
    else
      $('html,body').animate
        scrollTop: $('.section:eq(1)').offset().top
      ,
      500
    false

  #
  # And again, on the home page, if we were passed the hash, scroll down!
  if path == '/#design-button'
    document.location.href = '#'
    $('.design-button').click()


  ###
  
  All the stuff for the admin template designer
  is probably going to be in this section right here.

  ok.

  ###
  #
  # Only an admin page, do this stuff
  if path == '/admin'


    # Grab all the guys we're going to use
    $designer = $ '.designer'
    #
    $card = $designer.find '.card'
    $qr = $card.find '.qr'
    $lines = $card.find '.line'
    $body = $ document
    #
    $cat = $designer.find '.category-field input'
    #
    $color1 = $designer.find '.color1'
    $color2 = $designer.find '.color2'
    #
    $notfonts = $designer.find '.not-font-style'
    $fonts = $designer.find '.font-style'
    $font_color = $fonts.find '.color'
    $font_family = $fonts.find '.font-family'
    #
    $dForm = $designer.find 'form'
    $upload = $dForm.find '[type=file]'
    #
    # Set some constants
    card_height = $card.outerHeight()
    card_width = $card.outerWidth()
    card_inner_height = $card.height()
    card_inner_width = $card.width()
    active_theme = false
    #
    #
    ###
    GOOGLE FONTS

    1. Load them
    2. Make their common names available

    ###

    # Loading Them
    setTimeout ->
      WebFont.load google:
        families: [ "IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin" ]
    ,3000

    # Common Names
    font_families = ['Arial','Comic Sans MS','Courier New','Georgia','Impact','Times New Roman','Trebuchet MS','Verdana','IM Fell English SC','Julee','Syncopate','Gravitas One','Quicksand','Vast Shadow','Smokum','Ovo','Amatic SC','Rancho','Poly','Chivo','Prata','Abril Fatface','Ultra','Love Ya Like A Sister','Carter One','Luckiest Guy','Gruppo','Slackey'].sort()

    ###
    END GOOGLE FONTS
    ###
    #
    # Load in those font families
    $font_family.find('option').remove()
    for fam in font_families
      $font_family.append '<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>'

    #
    # QRs and Lines are hidden By default
    $qr.hide()
    $lines.hide()

    #
    # QR Code
    ht = 500
    wd = 500
    console.log wd, ht
    $qr.html '<canvas class="canvas" />'
    elem = $qr.find('.canvas')[0]
    qrc = elem.getContext("2d")
    qrc.canvas.width = wd
    qrc.canvas.height = ht
    d = document
    ecclevel = 1
    qf = genframe('http://cards.ly/fdasfs')
    ###
    qrc.lineWidth = 4
    console.log width
    i = undefined
    j = undefined
    px = wd
    px = ht  if ht < wd
    px /= width + 10
    px = Math.round(px - 0.5)
    console.log px
    qrc.clearRect 0, 0, wd, ht
    qrc.fillStyle = "#fff"
    qrc.fillRect 0, 0, px * (width + 8), px * (width + 8)
    qrc.fillStyle = "#000"
    i = 0
    while i < width
      j = 0
      while j < width
        qrc.fillRect px * (i + 4), px * (j + 4), px, px  if qf[j * width + i]
        j++
      i++
    ###
    
    #
    # Key up and down events for active lines
    shiftAmount = 1
    $body.keydown (e) ->
      $active_item = $card.find '.active'
      c = e.keyCode
      #
      # Only if we have a live one, do we do anything with this
      if $active_item.length #and not $font_color.is(':focus') and not $font_family.is(':focus')
        #
        # Modify the amount we shift when the shift key is pressed :D
        # (apparently I like using confusing variable names, ha)
        if e.keyCode is 16 then shiftAmount = 10
        #
        # Up and Down Events
        if c is 38 or c is 40
          #
          # Find out how far the user asked to move
          new_top = parseInt($active_item.css('top'))
          if c is 38 then new_top -= shiftAmount
          if c is 40 then new_top += shiftAmount
          #
          # Find out our boundary
          top_bound = (card_height - card_inner_height)/2
          bottom_bound = top_bound + card_inner_height - $active_item.outerHeight()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_top < top_bound then new_top = top_bound
          if new_top > bottom_bound then new_top = bottom_bound
          #
          # Then set it
          $active_item.css 'top', new_top
        #
        # Left and Right
        if c is 37 or c is 39
          #
          # Find out how far the user asked to move
          new_left = parseInt($active_item.css('left'))
          if c is 37 then new_left -= shiftAmount
          if c is 39 then new_left += shiftAmount
          #
          # Find out our boundary
          top_bound = (card_width - card_inner_width)/2
          bottom_bound = top_bound + card_inner_width - $active_item.outerWidth()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_left < top_bound then new_left = top_bound
          if new_left > bottom_bound then new_left = bottom_bound
          #
          # Then set it
          $active_item.css 'left', new_left
        #
        # Always return false on the arrow key presses
        if c is 38 or c is 40 or c is 39 or c is 37 then return false
    $body.keyup (e) ->
      if e.keyCode is 16 then shiftAmount = 1
    #
    # Changing font family on select change
    update_family = ->
      console.log 1
      $t = $ this
      $active_item = $card.find('.active')
      #
      # Update it all
      $active_item.css
        'font-family': $t.val()
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      active_theme.positions[index+1].font_family = $t.val()
    #
    $font_family.change update_family
    #
    #
    $font_color.ColorPicker
      livePreview: true
      onChange: (hsb, hex, rgb) ->
        $font_color.val hex
        $font_color.keyup()
    #
    # Changing font color on key presses
    $font_color.keyup ->
      $t = $ this
      $active_item = $card.find('.active')
      #
      # Update it all
      $active_item.css
        color: '#'+$t.val()
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      active_theme.positions[index+1].color = $t.val()
    #
    # 
    #
    # Helper function for highlighting going away
    unfocus_highlight = (e) ->
      $t = $ e.target
      if $t.hasClass('font-style') or $t.closest('.font-style').length or $t.hasClass('line') or $t.hasClass('qr') or $t.closest('.line').length or $t.closest('.qr').length or $t.closest('.colorpicker').length
        $t = null
      else
        $card.find('.active').removeClass 'active'
        $body.unbind 'click', unfocus_highlight
        $fonts.stop(true,false).slideUp()
        $notfonts.stop(true,false).slideDown()
        return false
    #
    # Highlighting and making a line the active one
    $lines.mousedown ->
      #
      # Set it up and make it active
      $t = $ this
      $pa = $card.find '.active'
      $pa.removeClass 'active'
      $t.addClass 'active'
      #
      # Allow body clicks to unfocus it
      $body.bind 'click', unfocus_highlight
      #
      # Find it's index relative to it's peers
      index = $t.prevAll().length
      $fonts.stop(true,false).slideDown()
      $notfonts.stop(true,false).slideUp()
      $font_color.val active_theme.positions[index+1].color
      $font_family.find('option[value="' + active_theme.positions[index+1].font_family + '"]').attr 'selected', 'selected'
    #
    # Highlighting and making a line the active one
    $qr.mousedown ->
      $t = $ this
      $pa = $card.find '.active'
      $pa.removeClass 'active'
      $t.addClass 'active'
      $body.bind 'click', unfocus_highlight
      $fonts.stop(true,false).slideUp()
      $notfonts.stop(true,false).slideDown()

    #
    # A global page timer for the automatic save event.
    pageTimer = 0
    setPageTimer = ->
      clearTimeout pageTimer
      pageTimer = setTimeout ->
        execute_save()
      , 500 # This will be 5000 or higher eventually, 500 for now for testing. I'm impatient :D :D :D

    #
    # Set that timer on the right events for the right things
    $cat.keyup setPageTimer
    $font_color.keyup setPageTimer
    $color1.keyup setPageTimer
    $color2.keyup setPageTimer

    #
    # The dragging and dropping functions for lines
    $lines.draggable
      grid: [10,10]
      containment: '.designer .card'
      stop: setPageTimer
    $lines.resizable
      grid: 10
      handles: 'n, e, s, w, se'
      resize: (e, ui) ->
        $(ui.element).css
          'font-size': ui.size.height + 'px'
          'line-height': ui.size.height + 'px'
      stop: setPageTimer
    #
    # Dragging and dropping functions for the qr code
    $qr.draggable
      grid: [5,5]
      containment: '.designer .card'
      stop: setPageTimer
    $qr.resizable
      grid: 5
      containment: '.designer .card'
      handles: 'n, e, s, w, ne, nw, se, sw'
      aspectRatio: 1
      stop: setPageTimer
    #

    #
    # On upload selection, submit that form
    $upload.change ->
      $dForm.submit()

    #
    # 6 and 12 selectors in the thumbnails
    $('.theme-1,.theme-2').click ->
      $t = $ this
      $c = $t.closest '.card'

      $c.click()

      # Actual Switch the classes
      $('.theme-1,.theme-2').removeClass 'active'
      $t.addClass 'active'

      # always return false to prevent href from going anywhere
      false

    #
    # Helper Function for getting the position in percentage from an elements top, left, height and width
    getPosition = ($t) ->
      # Get it's CSS Values
      height = parseInt $t.height()
      width = parseInt $t.width()
      left = parseInt $t.css 'left'
      top = parseInt $t.css 'top'
      #
      # Stop me if something went wrong :)
      if isNaN(height) or isNaN(width) or isNaN(top) or isNaN(left)
         return false
      #
      # Calculate a percentage and send it
      result = 
        h: Math.round(height / card_height * 10000) / 100
        w: Math.round(width / card_width * 10000) / 100
        x: Math.round(left / card_width * 10000) / 100
        y: Math.round(top / card_height * 10000) / 100
    #
    # Do the actual save.
    #
    # It should be noted, that in most cases, this just means saving into the session
    # Only on save button click does it pass an extra parameter to save it to a record in the database
    execute_save = (next) ->
      theme =
        _id: active_theme._id
        category: $cat.val()
        positions: []
        color1: $color1.val()
        color2: $color2.val()
        s3_id: active_theme.s3_id
      #
      # Get the position of the qr
      theme.positions.push getPosition $qr
      #
      # Get the position of each line
      $lines.each ->
        $t = $ this
        pos = getPosition $t
        if pos
          theme.positions.push pos
      #
      # Set the parameters
      parameters =
        theme: theme
        do_save: if next then true else false
      #
      $.ajax
        url: '/saveTheme'
        #
        # jQuery's default data parser does well with simple objects, but with complex ones it doesn't do quite what we need.
        # So in this case, we need to stringify first, doing our own conversion to a string to transmit across the 
        # interwebs to our server.
        #
        # (and correspondingly, the server does a JSON parse of the raw body instead of it's usual parsing.)
        data: JSON.stringify parameters
        success: (serverResponse) ->
          if !serverResponse.success
            $designer.find('.save').showTooltip
              message: 'Error saving.'
          if next then next()
        error: ->
          $designer.find('.save').showTooltip
            message: 'Error saving.'
          if next then next()


    #
    # This catches the script parent.window call sent from app.coffee on the s3 form submit
    $.s3_result = (s3_id) ->
      if not noTheme() and s3_id
        active_theme.s3_id = s3_id
        $card.css
          background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
      else
        loadAlert
          content: 'I had trouble saving that image, please try again later.'

    #
    # Function that is called to verify a theme is selected, warns if not.
    noTheme = ->
      if !active_theme
        loadAlert
          content: 'Please create or select a theme first'
        true
      else
        false

    #
    # Default Template for Card Designer
    default_theme = 
      category: ''
      color1: 'FFFFFF'
      color2: '000000'
      s3_id: ''
      positions: [
        h: 45
        w: 45
        x: 70
        y: 40
      ]
    for i in [0..5]
      default_theme.positions.push
        color: '000000'
        font_family: 'Vast Shadow'
        h: 7
        w: 50
        x: 5
        y: 5+i*10
    #
    # The general load theme function
    # It's for putting a theme into the designer for editing
    loadTheme = (theme) ->
      active_theme = theme
      qr = theme.positions.shift()
      $qr.show().css
        top: qr.y/100 * card_height
        left: qr.x/100 * card_width
        height: qr.h/100 * card_height
        width: qr.w/100 * card_height
      for pos,i in theme.positions
        $li = $lines.eq i
        $li.show().css
          top: pos.y/100 * card_height
          left: pos.x/100 * card_width
          width: (pos.w/100 * card_width) + 'px'
          fontSize: (pos.h/100 * card_height) + 'px'
          lineHeight: (pos.h/100 * card_height) + 'px'
          fontFamily: pos.font_family
          color: '#'+pos.color
      theme.positions.unshift qr
      $cat.val theme.category
      $color1.val theme.color1
      $color2.val theme.color2
    #
    # The add new button
    $('.add-new').click ->
      loadTheme(default_theme)

      # Oh wait, this doesn't happen until save, eh?
      ###
      $new_li = $ '<li class="card" />'
      $('.category[category=""] .gallery').append $new_li
      $new_li.click()
      ###


    #
    # On save click
    $designer.find('.buttons .save').click ->
      # Make sure we have something selected.
      if noTheme() then return false
      
      loadLoading {}, (closeLoading) ->
        execute_save ->
          closeLoading()
    #
    # On delete click
    $designer.find('.buttons .delete').click ->
      if noTheme() then return false
      loadModal
        content: '<p>Are you sure you want to permanently delete this template?</p>'
        height: 160
        width: 440
        buttons: [{
          label: 'Delete'
          action: (closeFunc) ->
            ###
            TODO: Make this delete the template

            So send to the server to delete the template we're on here ...

            ###
            closeFunc()
          },{
          class: 'gray'
          label: 'Cancel'
          action: (closeFunc) ->
            closeFunc()
          }
        ]
    
  #
  # Successful Login Function
  successfulLogin = ->
    if path == '/login'
      document.location.href = '/admin'
    else
      $s = $ '.signins' 
      $s.fadeOut 500, ->
        $s.html 'You are now logged in, please continue.'
        $s.fadeIn 1000
      $('.login a').attr('href','/logout').html 'Logout'


  # Window and Main Card to use later
  $win = $ window
  $mc = $ '.main.card'

  # Set up the hasHidden array with all of non visible sections
  winH = $win.height()+$win.scrollTop()
  hasHidden = []
  $('.section-to-hide').each ->
    $this = $(this)
    thisT = $this.offset().top
    if(winH<thisT)
      hasHidden.push
        $this: $this
        thisT: thisT
  # Hide them
  for i in hasHidden
    i.$this.hide()
  

  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  updateCards = (rowNumber, value) ->
    $('.card .content').each -> $(this).find('li:eq('+rowNumber+')').html value


  # On the window scroll event ...
  $win.scroll ->

    # Get the new bottom of the window position
    newWinH = $win.height()+$win.scrollTop()
    if $mc.length
      # If the main card bottom is now visible
      if $mc.offset().top+$mc.height() < newWinH && !$mc.data 'didLoad'
        $mc.data 'didLoad', true
        timeLapse = 0
        $('.main.card').find('input').each (rowNumber) ->
          updateCards rowNumber, this.value
        $('.main.card .defaults').find('input').each (rowNumber) ->
          $t = $ this
          v = $t.val()
          $t.val ''
          timers = for j in [0..v.length]
            do (j) ->
              timer = setTimeout ->
                v_substring = v.substr 0,j
                $t.val v_substring
                updateCards rowNumber, v_substring
              ,timeLapse*70
              timeLapse++
              timer
          $t.bind 'clearMe', ->
            console.log $t.data 'cleared'
            if !$t.data 'cleared'
              for i in timers
                clearTimeout i
              $t.val ''
              updateCards rowNumber, ''
              $t.data 'cleared', true
          $t.bind 'focus', ->
            $t.trigger 'clearMe'


    # Show any hidden sections
    for i in hasHidden
      if i.thisT-50 < newWinH
        i.$this.fadeIn(2000)
  
  

  #loadAlert 'Test', (close) ->
    #close()
  
  ###
  Login stuff
  ###
  #
  #
  # Watch the popup windows every 200ms for when they set a cookie
  monitorForComplete = (openedWindow) ->
    $.cookie 'success-login', null
    checkTimer = setInterval ->
      if $.cookie 'success-login'
        successfulLogin()
        $.cookie 'success-login', null
        window.focus()
        openedWindow.close()
    ,200
  #
  # Specific Socials Setup
  $('.google').click () ->
    monitorForComplete window.open 'auth/google', 'auth', 'height=350,width=600'
    false
  $('.twitter').click () ->
    monitorForComplete window.open 'auth/twitter', 'auth', 'height=400,width=500'
    false
  $('.facebook').click () ->
    monitorForComplete window.open 'auth/facebook', 'auth', 'height=400,width=900'
    false
  $('.linkedin').click () ->
    monitorForComplete window.open 'auth/linkedin', 'auth', 'height=300,width=400'
    false
  #
  #
  #Regular Login
  $('.login-form').submit ->
    loadLoading {}, (loadingClose) ->
      $.ajax
        url: '/login'
        data:
          email: $('.email-login').val()
          password: $('.password-login').val()
        success: (data) ->
          loadingClose()
          if data.err
            loadAlert
              content: data.err
          else
            successfulLogin()
        error: (err) ->
          loadingClose()
          loadAlert
            content: 'Our apologies. A server error occurred.'
    false
  #
  # New Login Creation
  $('.new').click () ->
    loadModal
      content: '<div class="create-form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>'
      buttons: [
        label: 'Create New'
        action: (formClose) ->
          email = $ '.email'
          password = $ '.password'
          password2 = $ '.password2'

          err = false
          if email.val() == '' || password.val() == '' || password2.val() == ''
            err = 'Please enter an email once and the password twice.'
          else if password.val() != password2.val()
            err = 'I\'m sorry, I don\'t think those passwords match.'
          else if password.val().length<4
            err = 'Password should be a little longer, at least 4 characters.'
          if err
            loadAlert {content:err}
          else
            formClose()
            loadLoading {}, (loadingClose) ->
              $.ajax
                url: '/createUser'
                data:
                  email: email.val()
                  password: password.val()
                success: (data) ->
                  loadingClose()
                  if data.err
                    loadAlert
                      content: data.err
                  else
                    successfulLogin()
                error: (err) ->
                  loadingClose()
                  loadAlert
                    content: 'Our apologies. A server error occurred.'
              , 1000
      ]
      height: 340
      width: 400
    
    $('.email').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val().match /.{1,}@.{1,}\..{1,}/
          $t.removeClass('error').addClass 'valid'
          $.ajax
            url: '/checkEmail'
            data:
              email: $t.val()
            success: (fullResponseObject) ->
              if fullResponseObject.count==0
                $t.removeClass('error').addClass 'valid'
                $t.showTooltip
                  message: fullResponseObject.email+' is good'
              else
                $t.removeClass('valid').addClass 'error'
                $t.showTooltip
                  message:''+fullResponseObject.email+' is in use. Try signing in with a social login.'
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message: 'Is that an email?'
      ,1000
    $('.password').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val().length >= 4
          $t.removeClass('error').addClass 'valid'
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message: 'Just '+(6-$t.val().length)+' more characters please.'
      ,1000
    $('.password2').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val() == $('.password').val()
          $t.removeClass('error').addClass 'valid'
          $('.step-4').fadeTo 300, 1
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message:'Passwords should match please.'
      ,1000
    false
 
  $feedback_a = $ '.feedback a'
  $feedback_a.mouseover () ->
    $feedback = $ '.feedback'
    $feedback.stop(true,false).animate
      right: '-37px'
      ,250
  $feedback_a.mouseout () ->
    $feedback = $ '.feedback'
    $feedback.stop(true,false).animate
      right: '-45px'
      ,250

  # Change Password
  $('.change_password_button').click () ->

    

  ###

  
      
  #Feedback Button
  $feedback_a.click () ->
    loadModal
      content: '<div class="feedback-form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback-text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email" cols="40"></p></div>'
      width: 400
      height: 300
      buttons: [
        label: 'Send Feedback'
        action: (formClose) ->
          #Close the window
          formClose()
          loadLoading {}, (loadingClose) ->
            $.ajax
              url: '/sendFeedback'
              data:
                content: $('.feedback-text').val()
                email: $('.emailNotUser').val()
              success: (data) ->
                loadingClose()
                if data.err
                  loadAlert
                    content: data.err
                else
                  successfulFeedback() ->
                    $s.html 'Feedback Sent'
                    $s.fadeIn 100000
              error: (err) ->
                loadingClose()
                loadAlert
                  content: 'Our apologies. A server error occurred, feedback could not be sent.'
            , 1000
      ] 
    false
  # This is the code that makes the dropdown menu changes which chart is displayed on the account page

  $('#show_activity').change () ->
    $('#activity_container ul').hide('slow')
    e='#' + $(':selected', $(this)).attr 'name'
    $(e).show('slow')
  $('#activity_container ul').hide()

  #This is the code to make which card chart is dispaled based on the dropdown menu
  $('#show_card_chart').change () ->
    $('#chart_container ul').hide('slow')
    e='#' + $(':selected', $(this)).attr 'name'
    $(e).show('slow')
  $('#chart_container ul').hide()

         
  ###
  Shopping Cart Stuff
  ###
  #
  # Default Item Name
  item_name = '100 cards'
  #
  # Checkout button action, default error for now.
  $('.checkout').click () ->
    loadAlert
      content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
    false
  #
  # The floaty guy behind the gallery selection
  $gs = $ '.gallery-select'
  $gs.css
    left: -220
    top: 0
  $('.gallery .card').live 'click', () ->
    $t = $ this
    $('.card').removeClass 'active'
    $t.addClass('active')
    $findClass = $t.clone()
    className = $findClass.removeClass('card')[0].className
    $findClass.remove()
    $('.main').attr
      class: 'card main '+className
    if $gs.offset().top == $t.offset().top-10
      $gs.animate
        left: $t.offset().left-10
      ,500
    else
      $gs.stop(true,false).animate
        top: $t.offset().top-10
      ,500,'linear',() ->
          $gs.animate
            left: $t.offset().left-10
          ,500,'linear'
  $gs.bind 'activeMoved', ->
    $a = $ '.card.active'
    $gs.css
      left: $a.offset().left-10
      top: $a.offset().top-10
  $(window).load () ->
    $('.gallery:first .card:first').click()
  



  # Buttons everywhere need hover and click states
  $('.button').live 'mouseenter', ->
    $(this).addClass 'hover'
  .live 'mouseleave', ->
    $(this).removeClass 'hover'
  .live 'mousedown', ->
    $(this).addClass 'click'
  .live 'mouseup', ->
    $(this).removeClass 'click'

  # Define Margin
  newMargin = 0
  maxSlides = $('.slides li').length
  marginIncrement = 620
  maxSlides--

  ###
  # Home Page Stuff
  ###

  # 
  # Category Expand/Collapse
  $('.category h4').click () ->
    $t = $ this
    $c = $t.closest '.category'
    $g = $c.find '.gallery'
    $a = $ '.category.active'
    if !$c.hasClass 'active'
      $a.removeClass('active')
      $a.find('.gallery').show().slideUp 400
      $gs.hide()
      $c.find('.gallery').slideDown 400, ->
        $gs.show()
        $c.find('.card:first').click()
      $c.addClass('active')

  #
  # Form Fields
  $('.card.main input').each (i) ->
    $t = $ this
    $t.data 'timer', 0
    $t.keyup -> 
      updateCards i, this.value
      clearTimeout $t.data 'timer'
      $t.data 'timer',
        setTimeout ->
          $('.card.main input').each -> $(this).trigger 'clearMe'
          ###
          # TODO
          #
          # this.value should have a .replace ',' '\,'
          # on it so that we can use a comma character and escape anything.
          # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
          ###
          arrayOfInputValues = $.makeArray $('.card.main input').map -> this.value
          console.log arrayOfInputValues
          $.ajax
            url: '/saveForm'
            data:
              inputs: arrayOfInputValues.join('`~`')
          false
        ,1000
      false
  
  ###
  # Button Clicking Stuff
  ###
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'click change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    $('.order-total .price').html '$'+($q.val()*1 + $s.val()*1)


  # Show / Hide more fields
  $('.main-fields .more').click ->
    $('.main-fields .alt').slideDown 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main-fields .less').show()
    false
  $('.main-fields .less').hide().click ->
    $('.main-fields .alt').slideUp 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main-fields .more').show()
    false

  # each advance of the slide
  advanceSlide = ->
    if newMargin < maxSlides * -marginIncrement
      newMargin=0
    else if newMargin > 0
      newMargin = maxSlides * -marginIncrement

    $('.slides .content').stop(true,false).animate
      'margin-left': newMargin
    , 400

  # click events
  $('.slides .arrow-right').click ->
    marginIncrement = $('.slides').width()
    clearTimeout(timer)
    newMargin -= marginIncrement
    advanceSlide()
  $('.slides .arrow-left').click ->
    marginIncrement = $('.slides').width()
    clearTimeout(timer)
    newMargin -= -marginIncrement
    advanceSlide()

  # The timer that starts and then repeats (cancelled on click)
  timer = setTimeout ->
    marginIncrement = $('.slides').width()
    newMargin -= marginIncrement
    advanceSlide()
    clearTimeout(timer)
    timer = setInterval ->
      marginIncrement = $('.slides').width()
      newMargin -= marginIncrement
      advanceSlide()
    , 6500
  , 3000


  $slides = $ '.slides'
  $slides.animate
    'padding-left':'301px'


    
