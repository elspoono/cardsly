QRRSBlock = (totalCount, dataCount) ->
  @totalCount = totalCount
  @dataCount = dataCount
class QR8bitByte
  constructor: (data) ->
    @mode = QRMode.MODE_8BIT_BYTE
    @data = data
  getLength: (buffer) ->
    @data.length

  write: (buffer) ->
    i = 0

    while i < @data.length
      buffer.put @data.charCodeAt(i), 8
      i++

class QRCode
  constructor: (typeNumber, errorCorrectLevel) ->
    @typeNumber = typeNumber
    @errorCorrectLevel = errorCorrectLevel
    @modules = null
    @moduleCount = 0
    @dataCache = null
    @dataList = new Array()
  addData: (data) ->
    newData = new QR8bitByte(data)
    @dataList.push newData
    @dataCache = null

  isDark: (row, col) ->
    return false  if row < 0 or @moduleCount <= row or col < 0 or @moduleCount <= col
    @modules[row][col]

  getModuleCount: ->
    @moduleCount

  make: ->
    if @typeNumber < 1
      typeNumber = 1
      typeNumber = 1
      while typeNumber < 40
        rsBlocks = QRRSBlock.getRSBlocks(typeNumber, @errorCorrectLevel)
        buffer = new QRBitBuffer()
        totalDataCount = 0
        i = 0

        while i < rsBlocks.length
          totalDataCount += rsBlocks[i].dataCount
          i++
        i = 0

        while i < @dataList.length
          data = @dataList[i]
          buffer.put data.mode, 4
          buffer.put data.getLength(), QRUtil.getLengthInBits(data.mode, typeNumber)
          data.write buffer
          i++
        break  if buffer.getLengthInBits() <= totalDataCount * 8
        typeNumber++
      @typeNumber = typeNumber
    @makeImpl false, @getBestMaskPattern()

  makeImpl: (test, maskPattern) ->
    @moduleCount = @typeNumber * 4 + 17
    @modules = new Array(@moduleCount)
    row = 0

    while row < @moduleCount
      @modules[row] = new Array(@moduleCount)
      col = 0

      while col < @moduleCount
        @modules[row][col] = null
        col++
      row++
    @setupPositionProbePattern 0, 0
    @setupPositionProbePattern @moduleCount - 7, 0
    @setupPositionProbePattern 0, @moduleCount - 7
    @setupPositionAdjustPattern()
    @setupTimingPattern()
    @setupTypeInfo test, maskPattern
    @setupTypeNumber test  if @typeNumber >= 7
    @dataCache = QRCode.createData(@typeNumber, @errorCorrectLevel, @dataList)  unless @dataCache?
    @mapData @dataCache, maskPattern

  setupPositionProbePattern: (row, col) ->
    r = -1

    while r <= 7
      if row + r <= -1 or @moduleCount <= row + r
        r++
        continue
      c = -1

      while c <= 7
        if col + c <= -1 or @moduleCount <= col + c
          c++
          continue
        if (0 <= r and r <= 6 and (c is 0 or c is 6)) or (0 <= c and c <= 6 and (r is 0 or r is 6)) or (2 <= r and r <= 4 and 2 <= c and c <= 4)
          @modules[row + r][col + c] = true
        else
          @modules[row + r][col + c] = false
        c++
      r++

  getBestMaskPattern: ->
    minLostPoint = 0
    pattern = 0
    i = 0

    while i < 8
      @makeImpl true, i
      lostPoint = QRUtil.getLostPoint(this)
      if i is 0 or minLostPoint > lostPoint
        minLostPoint = lostPoint
        pattern = i
      i++
    pattern

  createMovieClip: (target_mc, instance_name, depth) ->
    qr_mc = target_mc.createEmptyMovieClip(instance_name, depth)
    cs = 1
    @make()
    row = 0

    while row < @modules.length
      y = row * cs
      col = 0

      while col < @modules[row].length
        x = col * cs
        dark = @modules[row][col]
        if dark
          qr_mc.beginFill 0, 100
          qr_mc.moveTo x, y
          qr_mc.lineTo x + cs, y
          qr_mc.lineTo x + cs, y + cs
          qr_mc.lineTo x, y + cs
          qr_mc.endFill()
        col++
      row++
    qr_mc

  setupTimingPattern: ->
    r = 8

    while r < @moduleCount - 8
      if @modules[r][6]?
        r++
        continue
      @modules[r][6] = (r % 2 is 0)
      r++
    c = 8

    while c < @moduleCount - 8
      if @modules[6][c]?
        c++
        continue
      @modules[6][c] = (c % 2 is 0)
      c++

  setupPositionAdjustPattern: ->
    pos = QRUtil.getPatternPosition(@typeNumber)
    i = 0

    while i < pos.length
      j = 0

      while j < pos.length
        row = pos[i]
        col = pos[j]
        if @modules[row][col]?
          j++
          continue
        r = -2

        while r <= 2
          c = -2

          while c <= 2
            if r is -2 or r is 2 or c is -2 or c is 2 or (r is 0 and c is 0)
              @modules[row + r][col + c] = true
            else
              @modules[row + r][col + c] = false
            c++
          r++
        j++
      i++

  setupTypeNumber: (test) ->
    bits = QRUtil.getBCHTypeNumber(@typeNumber)
    i = 0

    while i < 18
      mod = (not test and ((bits >> i) & 1) is 1)
      @modules[Math.floor(i / 3)][i % 3 + @moduleCount - 8 - 3] = mod
      i++
    i = 0

    while i < 18
      mod = (not test and ((bits >> i) & 1) is 1)
      @modules[i % 3 + @moduleCount - 8 - 3][Math.floor(i / 3)] = mod
      i++

  setupTypeInfo: (test, maskPattern) ->
    data = (@errorCorrectLevel << 3) | maskPattern
    bits = QRUtil.getBCHTypeInfo(data)
    i = 0

    while i < 15
      mod = (not test and ((bits >> i) & 1) is 1)
      if i < 6
        @modules[i][8] = mod
      else if i < 8
        @modules[i + 1][8] = mod
      else
        @modules[@moduleCount - 15 + i][8] = mod
      i++
    i = 0

    while i < 15
      mod = (not test and ((bits >> i) & 1) is 1)
      if i < 8
        @modules[8][@moduleCount - i - 1] = mod
      else if i < 9
        @modules[8][15 - i - 1 + 1] = mod
      else
        @modules[8][15 - i - 1] = mod
      i++
    @modules[@moduleCount - 8][8] = (not test)

  mapData: (data, maskPattern) ->
    inc = -1
    row = @moduleCount - 1
    bitIndex = 7
    byteIndex = 0
    col = @moduleCount - 1

    while col > 0
      col--  if col is 6
      loop
        c = 0

        while c < 2
          unless @modules[row][col - c]?
            dark = false
            dark = (((data[byteIndex] >>> bitIndex) & 1) is 1)  if byteIndex < data.length
            mask = QRUtil.getMask(maskPattern, row, col - c)
            dark = not dark  if mask
            @modules[row][col - c] = dark
            bitIndex--
            if bitIndex is -1
              byteIndex++
              bitIndex = 7
          c++
        row += inc
        if row < 0 or @moduleCount <= row
          row -= inc
          inc = -inc
          break
      col -= 2

QRCode.PAD0 = 0xEC
QRCode.PAD1 = 0x11
QRCode.createData = (typeNumber, errorCorrectLevel, dataList) ->
  rsBlocks = QRRSBlock.getRSBlocks(typeNumber, errorCorrectLevel)
  buffer = new QRBitBuffer()
  i = 0

  while i < dataList.length
    data = dataList[i]
    buffer.put data.mode, 4
    buffer.put data.getLength(), QRUtil.getLengthInBits(data.mode, typeNumber)
    data.write buffer
    i++
  totalDataCount = 0
  i = 0

  while i < rsBlocks.length
    totalDataCount += rsBlocks[i].dataCount
    i++
  throw new Error("code length overflow. (" + buffer.getLengthInBits() + ">" + totalDataCount * 8 + ")")  if buffer.getLengthInBits() > totalDataCount * 8
  buffer.put 0, 4  if buffer.getLengthInBits() + 4 <= totalDataCount * 8
  buffer.putBit false  until buffer.getLengthInBits() % 8 is 0
  loop
    break  if buffer.getLengthInBits() >= totalDataCount * 8
    buffer.put QRCode.PAD0, 8
    break  if buffer.getLengthInBits() >= totalDataCount * 8
    buffer.put QRCode.PAD1, 8
  QRCode.createBytes buffer, rsBlocks

QRCode.createBytes = (buffer, rsBlocks) ->
  offset = 0
  maxDcCount = 0
  maxEcCount = 0
  dcdata = new Array(rsBlocks.length)
  ecdata = new Array(rsBlocks.length)
  r = 0

  while r < rsBlocks.length
    dcCount = rsBlocks[r].dataCount
    ecCount = rsBlocks[r].totalCount - dcCount
    maxDcCount = Math.max(maxDcCount, dcCount)
    maxEcCount = Math.max(maxEcCount, ecCount)
    dcdata[r] = new Array(dcCount)
    i = 0

    while i < dcdata[r].length
      dcdata[r][i] = 0xff & buffer.buffer[i + offset]
      i++
    offset += dcCount
    rsPoly = QRUtil.getErrorCorrectPolynomial(ecCount)
    rawPoly = new QRPolynomial(dcdata[r], rsPoly.getLength() - 1)
    modPoly = rawPoly.mod(rsPoly)
    ecdata[r] = new Array(rsPoly.getLength() - 1)
    i = 0

    while i < ecdata[r].length
      modIndex = i + modPoly.getLength() - ecdata[r].length
      ecdata[r][i] = (if (modIndex >= 0) then modPoly.get(modIndex) else 0)
      i++
    r++
  totalCodeCount = 0
  i = 0

  while i < rsBlocks.length
    totalCodeCount += rsBlocks[i].totalCount
    i++
  data = new Array(totalCodeCount)
  index = 0
  i = 0

  while i < maxDcCount
    r = 0

    while r < rsBlocks.length
      data[index++] = dcdata[r][i]  if i < dcdata[r].length
      r++
    i++
  i = 0

  while i < maxEcCount
    r = 0

    while r < rsBlocks.length
      data[index++] = ecdata[r][i]  if i < ecdata[r].length
      r++
    i++
  data

QRMode =
  MODE_NUMBER: 1 << 0
  MODE_ALPHA_NUM: 1 << 1
  MODE_8BIT_BYTE: 1 << 2
  MODE_KANJI: 1 << 3

QRErrorCorrectLevel =
  L: 1
  M: 0
  Q: 3
  H: 2

QRMaskPattern =
  PATTERN000: 0
  PATTERN001: 1
  PATTERN010: 2
  PATTERN011: 3
  PATTERN100: 4
  PATTERN101: 5
  PATTERN110: 6
  PATTERN111: 7

QRUtil =
  PATTERN_POSITION_TABLE: [ [], [ 6, 18 ], [ 6, 22 ], [ 6, 26 ], [ 6, 30 ], [ 6, 34 ], [ 6, 22, 38 ], [ 6, 24, 42 ], [ 6, 26, 46 ], [ 6, 28, 50 ], [ 6, 30, 54 ], [ 6, 32, 58 ], [ 6, 34, 62 ], [ 6, 26, 46, 66 ], [ 6, 26, 48, 70 ], [ 6, 26, 50, 74 ], [ 6, 30, 54, 78 ], [ 6, 30, 56, 82 ], [ 6, 30, 58, 86 ], [ 6, 34, 62, 90 ], [ 6, 28, 50, 72, 94 ], [ 6, 26, 50, 74, 98 ], [ 6, 30, 54, 78, 102 ], [ 6, 28, 54, 80, 106 ], [ 6, 32, 58, 84, 110 ], [ 6, 30, 58, 86, 114 ], [ 6, 34, 62, 90, 118 ], [ 6, 26, 50, 74, 98, 122 ], [ 6, 30, 54, 78, 102, 126 ], [ 6, 26, 52, 78, 104, 130 ], [ 6, 30, 56, 82, 108, 134 ], [ 6, 34, 60, 86, 112, 138 ], [ 6, 30, 58, 86, 114, 142 ], [ 6, 34, 62, 90, 118, 146 ], [ 6, 30, 54, 78, 102, 126, 150 ], [ 6, 24, 50, 76, 102, 128, 154 ], [ 6, 28, 54, 80, 106, 132, 158 ], [ 6, 32, 58, 84, 110, 136, 162 ], [ 6, 26, 54, 82, 110, 138, 166 ], [ 6, 30, 58, 86, 114, 142, 170 ] ]
  G15: (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0)
  G18: (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0)
  G15_MASK: (1 << 14) | (1 << 12) | (1 << 10) | (1 << 4) | (1 << 1)
  getBCHTypeInfo: (data) ->
    d = data << 10
    d ^= (QRUtil.G15 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15)))  while QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15) >= 0
    ((data << 10) | d) ^ QRUtil.G15_MASK

  getBCHTypeNumber: (data) ->
    d = data << 12
    d ^= (QRUtil.G18 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18)))  while QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18) >= 0
    (data << 12) | d

  getBCHDigit: (data) ->
    digit = 0
    until data is 0
      digit++
      data >>>= 1
    digit

  getPatternPosition: (typeNumber) ->
    QRUtil.PATTERN_POSITION_TABLE[typeNumber - 1]

  getMask: (maskPattern, i, j) ->
    switch maskPattern
      when QRMaskPattern.PATTERN000
        (i + j) % 2 is 0
      when QRMaskPattern.PATTERN001
        i % 2 is 0
      when QRMaskPattern.PATTERN010
        j % 3 is 0
      when QRMaskPattern.PATTERN011
        (i + j) % 3 is 0
      when QRMaskPattern.PATTERN100
        (Math.floor(i / 2) + Math.floor(j / 3)) % 2 is 0
      when QRMaskPattern.PATTERN101
        (i * j) % 2 + (i * j) % 3 is 0
      when QRMaskPattern.PATTERN110
        ((i * j) % 2 + (i * j) % 3) % 2 is 0
      when QRMaskPattern.PATTERN111
        ((i * j) % 3 + (i + j) % 2) % 2 is 0
      else
        throw new Error("bad maskPattern:" + maskPattern)

  getErrorCorrectPolynomial: (errorCorrectLength) ->
    a = new QRPolynomial([ 1 ], 0)
    i = 0

    while i < errorCorrectLength
      a = a.multiply(new QRPolynomial([ 1, QRMath.gexp(i) ], 0))
      i++
    a

  getLengthInBits: (mode, type) ->
    if 1 <= type and type < 10
      switch mode
        when QRMode.MODE_NUMBER
          10
        when QRMode.MODE_ALPHA_NUM
          9
        when QRMode.MODE_8BIT_BYTE
          8
        when QRMode.MODE_KANJI
          8
        else
          throw new Error("mode:" + mode)
    else if type < 27
      switch mode
        when QRMode.MODE_NUMBER
          12
        when QRMode.MODE_ALPHA_NUM
          11
        when QRMode.MODE_8BIT_BYTE
          16
        when QRMode.MODE_KANJI
          10
        else
          throw new Error("mode:" + mode)
    else if type < 41
      switch mode
        when QRMode.MODE_NUMBER
          14
        when QRMode.MODE_ALPHA_NUM
          13
        when QRMode.MODE_8BIT_BYTE
          16
        when QRMode.MODE_KANJI
          12
        else
          throw new Error("mode:" + mode)
    else
      throw new Error("type:" + type)

  getLostPoint: (qrCode) ->
    moduleCount = qrCode.getModuleCount()
    lostPoint = 0
    row = 0

    while row < moduleCount
      col = 0

      while col < moduleCount
        sameCount = 0
        dark = qrCode.isDark(row, col)
        r = -1

        while r <= 1
          if row + r < 0 or moduleCount <= row + r
            r++
            continue
          c = -1

          while c <= 1
            if col + c < 0 or moduleCount <= col + c
              c++
              continue
            if r is 0 and c is 0
              c++
              continue
            sameCount++  if dark is qrCode.isDark(row + r, col + c)
            c++
          r++
        lostPoint += (3 + sameCount - 5)  if sameCount > 5
        col++
      row++
    row = 0

    while row < moduleCount - 1
      col = 0

      while col < moduleCount - 1
        count = 0
        count++  if qrCode.isDark(row, col)
        count++  if qrCode.isDark(row + 1, col)
        count++  if qrCode.isDark(row, col + 1)
        count++  if qrCode.isDark(row + 1, col + 1)
        lostPoint += 3  if count is 0 or count is 4
        col++
      row++
    row = 0

    while row < moduleCount
      col = 0

      while col < moduleCount - 6
        lostPoint += 40  if qrCode.isDark(row, col) and not qrCode.isDark(row, col + 1) and qrCode.isDark(row, col + 2) and qrCode.isDark(row, col + 3) and qrCode.isDark(row, col + 4) and not qrCode.isDark(row, col + 5) and qrCode.isDark(row, col + 6)
        col++
      row++
    col = 0

    while col < moduleCount
      row = 0

      while row < moduleCount - 6
        lostPoint += 40  if qrCode.isDark(row, col) and not qrCode.isDark(row + 1, col) and qrCode.isDark(row + 2, col) and qrCode.isDark(row + 3, col) and qrCode.isDark(row + 4, col) and not qrCode.isDark(row + 5, col) and qrCode.isDark(row + 6, col)
        row++
      col++
    darkCount = 0
    col = 0

    while col < moduleCount
      row = 0

      while row < moduleCount
        darkCount++  if qrCode.isDark(row, col)
        row++
      col++
    ratio = Math.abs(100 * darkCount / moduleCount / moduleCount - 50) / 5
    lostPoint += ratio * 10
    lostPoint

QRMath =
  glog: (n) ->
    throw new Error("glog(" + n + ")")  if n < 1
    QRMath.LOG_TABLE[n]

  gexp: (n) ->
    n += 255  while n < 0
    n -= 255  while n >= 256
    QRMath.EXP_TABLE[n]

  EXP_TABLE: new Array(256)
  LOG_TABLE: new Array(256)

i = 0

while i < 8
  QRMath.EXP_TABLE[i] = 1 << i
  i++
i = 8

while i < 256
  QRMath.EXP_TABLE[i] = QRMath.EXP_TABLE[i - 4] ^ QRMath.EXP_TABLE[i - 5] ^ QRMath.EXP_TABLE[i - 6] ^ QRMath.EXP_TABLE[i - 8]
  i++
i = 0

while i < 255
  QRMath.LOG_TABLE[QRMath.EXP_TABLE[i]] = i
  i++
class QRPolynomial
  constructor: (num, shift) ->
    throw new Error(num.length + "/" + shift)  if num.length is `undefined`
    offset = 0
    offset++  while offset < num.length and num[offset] is 0
    @num = new Array(num.length - offset + shift)
    i = 0

    while i < num.length - offset
      @num[i] = num[i + offset]
      i++
  get: (index) ->
    @num[index]

  getLength: ->
    @num.length

  multiply: (e) ->
    num = new Array(@getLength() + e.getLength() - 1)
    i = 0

    while i < @getLength()
      j = 0

      while j < e.getLength()
        num[i + j] ^= QRMath.gexp(QRMath.glog(@get(i)) + QRMath.glog(e.get(j)))
        j++
      i++
    new QRPolynomial(num, 0)

  mod: (e) ->
    return this  if @getLength() - e.getLength() < 0
    ratio = QRMath.glog(@get(0)) - QRMath.glog(e.get(0))
    num = new Array(@getLength())
    i = 0

    while i < @getLength()
      num[i] = @get(i)
      i++
    i = 0

    while i < e.getLength()
      num[i] ^= QRMath.gexp(QRMath.glog(e.get(i)) + ratio)
      i++
    new QRPolynomial(num, 0).mod e

QRRSBlock.RS_BLOCK_TABLE = [ [ 1, 26, 19 ], [ 1, 26, 16 ], [ 1, 26, 13 ], [ 1, 26, 9 ], [ 1, 44, 34 ], [ 1, 44, 28 ], [ 1, 44, 22 ], [ 1, 44, 16 ], [ 1, 70, 55 ], [ 1, 70, 44 ], [ 2, 35, 17 ], [ 2, 35, 13 ], [ 1, 100, 80 ], [ 2, 50, 32 ], [ 2, 50, 24 ], [ 4, 25, 9 ], [ 1, 134, 108 ], [ 2, 67, 43 ], [ 2, 33, 15, 2, 34, 16 ], [ 2, 33, 11, 2, 34, 12 ], [ 2, 86, 68 ], [ 4, 43, 27 ], [ 4, 43, 19 ], [ 4, 43, 15 ], [ 2, 98, 78 ], [ 4, 49, 31 ], [ 2, 32, 14, 4, 33, 15 ], [ 4, 39, 13, 1, 40, 14 ], [ 2, 121, 97 ], [ 2, 60, 38, 2, 61, 39 ], [ 4, 40, 18, 2, 41, 19 ], [ 4, 40, 14, 2, 41, 15 ], [ 2, 146, 116 ], [ 3, 58, 36, 2, 59, 37 ], [ 4, 36, 16, 4, 37, 17 ], [ 4, 36, 12, 4, 37, 13 ], [ 2, 86, 68, 2, 87, 69 ], [ 4, 69, 43, 1, 70, 44 ], [ 6, 43, 19, 2, 44, 20 ], [ 6, 43, 15, 2, 44, 16 ], [ 4, 101, 81 ], [ 1, 80, 50, 4, 81, 51 ], [ 4, 50, 22, 4, 51, 23 ], [ 3, 36, 12, 8, 37, 13 ], [ 2, 116, 92, 2, 117, 93 ], [ 6, 58, 36, 2, 59, 37 ], [ 4, 46, 20, 6, 47, 21 ], [ 7, 42, 14, 4, 43, 15 ], [ 4, 133, 107 ], [ 8, 59, 37, 1, 60, 38 ], [ 8, 44, 20, 4, 45, 21 ], [ 12, 33, 11, 4, 34, 12 ], [ 3, 145, 115, 1, 146, 116 ], [ 4, 64, 40, 5, 65, 41 ], [ 11, 36, 16, 5, 37, 17 ], [ 11, 36, 12, 5, 37, 13 ], [ 5, 109, 87, 1, 110, 88 ], [ 5, 65, 41, 5, 66, 42 ], [ 5, 54, 24, 7, 55, 25 ], [ 11, 36, 12 ], [ 5, 122, 98, 1, 123, 99 ], [ 7, 73, 45, 3, 74, 46 ], [ 15, 43, 19, 2, 44, 20 ], [ 3, 45, 15, 13, 46, 16 ], [ 1, 135, 107, 5, 136, 108 ], [ 10, 74, 46, 1, 75, 47 ], [ 1, 50, 22, 15, 51, 23 ], [ 2, 42, 14, 17, 43, 15 ], [ 5, 150, 120, 1, 151, 121 ], [ 9, 69, 43, 4, 70, 44 ], [ 17, 50, 22, 1, 51, 23 ], [ 2, 42, 14, 19, 43, 15 ], [ 3, 141, 113, 4, 142, 114 ], [ 3, 70, 44, 11, 71, 45 ], [ 17, 47, 21, 4, 48, 22 ], [ 9, 39, 13, 16, 40, 14 ], [ 3, 135, 107, 5, 136, 108 ], [ 3, 67, 41, 13, 68, 42 ], [ 15, 54, 24, 5, 55, 25 ], [ 15, 43, 15, 10, 44, 16 ], [ 4, 144, 116, 4, 145, 117 ], [ 17, 68, 42 ], [ 17, 50, 22, 6, 51, 23 ], [ 19, 46, 16, 6, 47, 17 ], [ 2, 139, 111, 7, 140, 112 ], [ 17, 74, 46 ], [ 7, 54, 24, 16, 55, 25 ], [ 34, 37, 13 ], [ 4, 151, 121, 5, 152, 122 ], [ 4, 75, 47, 14, 76, 48 ], [ 11, 54, 24, 14, 55, 25 ], [ 16, 45, 15, 14, 46, 16 ], [ 6, 147, 117, 4, 148, 118 ], [ 6, 73, 45, 14, 74, 46 ], [ 11, 54, 24, 16, 55, 25 ], [ 30, 46, 16, 2, 47, 17 ], [ 8, 132, 106, 4, 133, 107 ], [ 8, 75, 47, 13, 76, 48 ], [ 7, 54, 24, 22, 55, 25 ], [ 22, 45, 15, 13, 46, 16 ], [ 10, 142, 114, 2, 143, 115 ], [ 19, 74, 46, 4, 75, 47 ], [ 28, 50, 22, 6, 51, 23 ], [ 33, 46, 16, 4, 47, 17 ], [ 8, 152, 122, 4, 153, 123 ], [ 22, 73, 45, 3, 74, 46 ], [ 8, 53, 23, 26, 54, 24 ], [ 12, 45, 15, 28, 46, 16 ], [ 3, 147, 117, 10, 148, 118 ], [ 3, 73, 45, 23, 74, 46 ], [ 4, 54, 24, 31, 55, 25 ], [ 11, 45, 15, 31, 46, 16 ], [ 7, 146, 116, 7, 147, 117 ], [ 21, 73, 45, 7, 74, 46 ], [ 1, 53, 23, 37, 54, 24 ], [ 19, 45, 15, 26, 46, 16 ], [ 5, 145, 115, 10, 146, 116 ], [ 19, 75, 47, 10, 76, 48 ], [ 15, 54, 24, 25, 55, 25 ], [ 23, 45, 15, 25, 46, 16 ], [ 13, 145, 115, 3, 146, 116 ], [ 2, 74, 46, 29, 75, 47 ], [ 42, 54, 24, 1, 55, 25 ], [ 23, 45, 15, 28, 46, 16 ], [ 17, 145, 115 ], [ 10, 74, 46, 23, 75, 47 ], [ 10, 54, 24, 35, 55, 25 ], [ 19, 45, 15, 35, 46, 16 ], [ 17, 145, 115, 1, 146, 116 ], [ 14, 74, 46, 21, 75, 47 ], [ 29, 54, 24, 19, 55, 25 ], [ 11, 45, 15, 46, 46, 16 ], [ 13, 145, 115, 6, 146, 116 ], [ 14, 74, 46, 23, 75, 47 ], [ 44, 54, 24, 7, 55, 25 ], [ 59, 46, 16, 1, 47, 17 ], [ 12, 151, 121, 7, 152, 122 ], [ 12, 75, 47, 26, 76, 48 ], [ 39, 54, 24, 14, 55, 25 ], [ 22, 45, 15, 41, 46, 16 ], [ 6, 151, 121, 14, 152, 122 ], [ 6, 75, 47, 34, 76, 48 ], [ 46, 54, 24, 10, 55, 25 ], [ 2, 45, 15, 64, 46, 16 ], [ 17, 152, 122, 4, 153, 123 ], [ 29, 74, 46, 14, 75, 47 ], [ 49, 54, 24, 10, 55, 25 ], [ 24, 45, 15, 46, 46, 16 ], [ 4, 152, 122, 18, 153, 123 ], [ 13, 74, 46, 32, 75, 47 ], [ 48, 54, 24, 14, 55, 25 ], [ 42, 45, 15, 32, 46, 16 ], [ 20, 147, 117, 4, 148, 118 ], [ 40, 75, 47, 7, 76, 48 ], [ 43, 54, 24, 22, 55, 25 ], [ 10, 45, 15, 67, 46, 16 ], [ 19, 148, 118, 6, 149, 119 ], [ 18, 75, 47, 31, 76, 48 ], [ 34, 54, 24, 34, 55, 25 ], [ 20, 45, 15, 61, 46, 16 ] ]
QRRSBlock.getRSBlocks = (typeNumber, errorCorrectLevel) ->
  rsBlock = QRRSBlock.getRsBlockTable(typeNumber, errorCorrectLevel)
  throw new Error("bad rs block @ typeNumber:" + typeNumber + "/errorCorrectLevel:" + errorCorrectLevel)  if rsBlock is `undefined`
  length = rsBlock.length / 3
  list = new Array()
  i = 0

  while i < length
    count = rsBlock[i * 3 + 0]
    totalCount = rsBlock[i * 3 + 1]
    dataCount = rsBlock[i * 3 + 2]
    j = 0

    while j < count
      list.push new QRRSBlock(totalCount, dataCount)
      j++
    i++
  list

QRRSBlock.getRsBlockTable = (typeNumber, errorCorrectLevel) ->
  switch errorCorrectLevel
    when QRErrorCorrectLevel.L
      QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 0]
    when QRErrorCorrectLevel.M
      QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 1]
    when QRErrorCorrectLevel.Q
      QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 2]
    when QRErrorCorrectLevel.H
      QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 3]
    else
      `undefined`

class QRBitBuffer
  constructor: ->
    @buffer = new Array()
    @length = 0
  get: (index) ->
    bufIndex = Math.floor(index / 8)
    ((@buffer[bufIndex] >>> (7 - index % 8)) & 1) is 1

  put: (num, length) ->
    i = 0

    while i < length
      @putBit ((num >>> (length - i - 1)) & 1) is 1
      i++

  getLengthInBits: ->
    @length

  putBit: (bit) ->
    bufIndex = Math.floor(@length / 8)
    @buffer.push 0  if @buffer.length <= bufIndex
    @buffer[bufIndex] |= (0x80 >>> (@length % 8))  if bit
    @length++






###
--------------------------------------------------------------------------------------------------------



Begin DB Customizations



--------------------------------------------------------------------------------------------------------
###
#
#
hex_to_rgba = (h) ->
  cut_hex = (h) -> if h.charAt(0)=="#" then h.substring(1,7) else h
  hex = cut_hex h
  r = parseInt hex.substring(0,2), 16
  g = parseInt hex.substring(2,4), 16
  b = parseInt hex.substring(4,6), 16
  a = hex.substring(6,8)
  if a
    a = (parseInt a, 16) / 255
  else
    a = 1
  if a is 1
    'rgb('+r+','+g+','+b+')'
  else
    'rgba('+r+','+g+','+b+','+a+')'
#
ctx_inverted_arc = (my_ctx, a, b, c, d) ->
  my_ctx.beginPath()
  my_ctx.moveTo c, b
  my_ctx.quadraticCurveTo a, b, a, d
  my_ctx.lineTo a, b
  my_ctx.lineTo c, b
  my_ctx.fill()
#
#
create_qr = (url) ->
    qrcode = new QRCode(-1, QRErrorCorrectLevel.H)
    qrcode.addData url
    qrcode.make()
    qrcode
#
###

USAGE

draw_qr
  node_canvas: node_canvas
  hex: '000000'
  hex_2: 'FFFFFF'
  style: 'circle'
  url: 'http://cards.ly'
  square_size: '10'

###
#
draw_qr = (o) ->
  #
  #
  o.square_size = 20 if not o.square_size
  #
  #
  if o.style is 'circle'
    o.round = 8
  else if o.style is 'square'
    o.round = 0
  else
    o.style = 'round'
    o.round = 10
  #
  #
  qr = create_qr o.url
  #
  #
  count = qr.moduleCount
  #
  #
  border_size = o.square_size * 2
  round = o.round
  #
  #
  quarter = o.square_size/2
  #
  #
  height = count * o.square_size + border_size * 3
  #
  width = count * o.square_size + border_size * 2
  #
  size = height
  #
  #
  #
  if o.node_canvas
    canvas = new o.node_canvas(width,height)
  if o.$canvas
    canvas = o.$canvas[0]
    o.$canvas.attr
      height: height
      width: width
  #
  #
  ctx = canvas.getContext '2d'
  ctx.fillStyle = hex_to_rgba o.hex
  #
  #
  if o.hex_2 isnt 'transparent'
    
    ctx.fillStyle = hex_to_rgba o.hex_2
    
    if o.style is 'square'
      ctx.fillRect 0, 0, width, height
    else
      ctx.beginPath()
      ctx.moveTo border_size, 0
      ctx.lineTo width-border_size, 0
      ctx.quadraticCurveTo width, 0, width, border_size
      ctx.lineTo width, height-border_size
      ctx.quadraticCurveTo width, height, width-border_size, height
      ctx.lineTo border_size, height
      ctx.quadraticCurveTo 0, height, 0, height-border_size
      ctx.lineTo 0, border_size
      ctx.quadraticCurveTo 0, 0, border_size, 0
      ctx.fill()

    ctx.fillStyle = hex_to_rgba o.hex


  for r in [0..count-1]
    for c in [0..count-1]
      #
      # r is the row we are on
      # ... and c is the column
      #
      # x and y are the top left starting points for our qr grid item
      #
      # o.square_size is the size of the grid item
      #
      # o.style is the type of drawing we are doing for that grid item
      #
      x = c*o.square_size+border_size
      y = r*o.square_size+border_size
        
      if qr.isDark r,c
        #
        #
        #
        if o.style is 'square'
          ctx.fillRect x, y, o.square_size, o.square_size
        #
        #
        if o.style is 'circle'
          ctx.beginPath()
          ctx.arc x+quarter, y+quarter, quarter+1, 0, Math.PI*2
          ctx.fill()
        #
        #
        if o.style is 'round'
          #
          ctx.beginPath()
          #
          # top middle
          ctx.moveTo x+quarter, y
          #
          # top right
          if qr.isDark(r,c+1) or qr.isDark(r-1,c)
            ctx.lineTo x+o.square_size, y
          else
            ctx.lineTo x+o.square_size-round, y
            ctx.quadraticCurveTo x+o.square_size, y, x+o.square_size, y+round
          #
          # bottom right
          if qr.isDark(r,c+1) or qr.isDark(r+1,c)
            ctx.lineTo x+o.square_size, y+o.square_size
          else
            ctx.lineTo x+o.square_size, y+o.square_size-round
            ctx.quadraticCurveTo x+o.square_size, y+o.square_size, x+o.square_size-round, y+o.square_size
          #
          # bottom left
          if qr.isDark(r,c-1) or qr.isDark(r+1,c)
            ctx.lineTo x, y+o.square_size
          else
            ctx.lineTo x+round, y+o.square_size
            ctx.quadraticCurveTo x, y+o.square_size, x, y+o.square_size-round
          #
          # top left
          if qr.isDark(r,c-1) or qr.isDark(r-1,c)
            ctx.lineTo x, y
          else
            ctx.lineTo x, y+round
            ctx.quadraticCurveTo x, y, x+round, y
          #
          #
          # return to top middle
          ctx.lineTo x+quarter, y
          #
          # fill it all in
          ctx.fill()
          #
          #
      else
        if o.style is 'round'
          #
          # top left
          if qr.isDark(r-1,c-1) and qr.isDark(r-1,c) and qr.isDark(r,c-1)
            ctx_inverted_arc ctx, x, y, x+quarter/2, y+quarter/2
          #
          # top right
          if qr.isDark(r-1,c) and qr.isDark(r-1,c+1) and qr.isDark(r,c+1)
            ctx_inverted_arc ctx, x+o.square_size, y, x+o.square_size-quarter/2, y+quarter/2
          #
          # bottom right
          if qr.isDark(r,c+1) and qr.isDark(r+1,c+1) and qr.isDark(r+1,c)
            ctx_inverted_arc ctx, x+o.square_size, y+o.square_size, x+o.square_size-quarter/2, y+o.square_size-quarter/2
          #
          # bottom left
          if qr.isDark(r,c-1) and qr.isDark(r+1,c-1) and qr.isDark(r+1,c)
            ctx_inverted_arc ctx, x, y+o.square_size, x+quarter/2, y+o.square_size-quarter/2
  #
  #
  # Draw the URL
  ctx.fillStyle = hex_to_rgba o.hex
  #
  #
  font_size = border_size*1.2
  ctx.font = font_size+'px Lato'
  parsed_url = o.url.replace('http:\/\/','')
  measure = ctx.measureText parsed_url, 0, 0
  ctx.fillText parsed_url, width-measure.width-border_size, height-font_size/5
  #
  #
  # Draw the Card Number
  if o.card_number
    ctx.fillText '#'+o.card_number, border_size, height-font_size/5
  #
  #
  # Return the canvas
  canvas
#
#
#
# used when required :)
unless typeof (exports) is "undefined"
  exports.create_qr = create_qr
  exports.draw_qr = draw_qr
#
#
#
# used when $ 'ed :)
unless typeof ($) is "undefined"
  $.create_qr = create_qr
  $.draw_qr = draw_qr