(function() {
  /*
   * 
   * Set settings / defaults
   * 
   * AJAX defaults
   * some constants
   * 
  */
  var $window, N1, N2, N3, N4, adelta, appendrs, applymask, badcheck, badruns, datablkw, dateFormat, eccblkwid, eccblocks, eccbuf, ecclevel, fmtword, framask, genframe, genpoly, gexp, glog, ht, ismasked, loadAlert, loadConfirm, loadLoading, loadModal, modnn, neccblk1, neccblk2, putalign, qrc, qrframe, rlens, setmask, strinbuf, usualDelay, version, vpat, wd, width;
  $.ajaxSetup({
    type: 'POST'
  });
  usualDelay = 4000;
  $window = $(window);
  $.fx.speeds._default = 300;
  setmask = function(x, y) {
    var bt;
    bt = void 0;
    if (x > y) {
      bt = x;
      x = y;
      y = bt;
    }
    bt = y;
    bt *= y;
    bt += y;
    bt >>= 1;
    bt += x;
    return framask[bt] = 1;
  };
  putalign = function(x, y) {
    var j, _results;
    j = void 0;
    qrframe[x + width * y] = 1;
    j = -2;
    while (j < 2) {
      qrframe[(x + j) + width * (y - 2)] = 1;
      qrframe[(x - 2) + width * (y + j + 1)] = 1;
      qrframe[(x + 2) + width * (y + j)] = 1;
      qrframe[(x + j + 1) + width * (y + 2)] = 1;
      j++;
    }
    j = 0;
    _results = [];
    while (j < 2) {
      setmask(x - 1, y + j);
      setmask(x + 1, y - j);
      setmask(x - j, y - 1);
      setmask(x + j, y + 1);
      _results.push(j++);
    }
    return _results;
  };
  modnn = function(x) {
    while (x >= 255) {
      x -= 255;
      x = (x >> 8) + (x & 255);
    }
    return x;
  };
  appendrs = function(data, dlen, ecbuf, eclen) {
    var fb, i, j, _results;
    i = void 0;
    j = void 0;
    fb = void 0;
    i = 0;
    while (i < eclen) {
      strinbuf[ecbuf + i] = 0;
      i++;
    }
    i = 0;
    _results = [];
    while (i < dlen) {
      fb = glog[strinbuf[data + i] ^ strinbuf[ecbuf]];
      if (fb !== 255) {
        j = 1;
        while (j < eclen) {
          strinbuf[ecbuf + j - 1] = strinbuf[ecbuf + j] ^ gexp[modnn(fb + genpoly[eclen - j])];
          j++;
        }
      } else {
        j = ecbuf;
        while (j < ecbuf + eclen) {
          strinbuf[j] = strinbuf[j + 1];
          j++;
        }
      }
      strinbuf[ecbuf + eclen - 1] = (fb === 255 ? 0 : gexp[modnn(fb + genpoly[0])]);
      _results.push(i++);
    }
    return _results;
  };
  ismasked = function(x, y) {
    var bt;
    bt = void 0;
    if (x > y) {
      bt = x;
      x = y;
      y = bt;
    }
    bt = y;
    bt += y * y;
    bt >>= 1;
    bt += x;
    return framask[bt];
  };
  applymask = function(m) {
    var r3x, r3y, x, y;
    x = void 0;
    y = void 0;
    r3x = void 0;
    r3y = void 0;
    switch (m) {
      case 0:
        y = 0;
        while (y < width) {
          x = 0;
          while (x < width) {
            if (!((x + y) & 1) && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
          }
          y++;
        }
        break;
      case 1:
        y = 0;
        while (y < width) {
          x = 0;
          while (x < width) {
            if (!(y & 1) && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
          }
          y++;
        }
        break;
      case 2:
        y = 0;
        while (y < width) {
          r3x = 0;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
            }
            if (!r3x && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
        }
        break;
      case 3:
        r3y = 0;
        y = 0;
        while (y < width) {
          if (r3y === 3) {
            r3y = 0;
          }
          r3x = r3y;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
            }
            if (!r3x && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
          r3y++;
        }
        break;
      case 4:
        y = 0;
        while (y < width) {
          r3x = 0;
          r3y = (y >> 1) & 1;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
              r3y = !r3y;
            }
            if (!r3y && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
        }
        break;
      case 5:
        r3y = 0;
        y = 0;
        while (y < width) {
          if (r3y === 3) {
            r3y = 0;
          }
          r3x = 0;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
            }
            if (!(x & y & 1) + !(!r3x | !r3y) && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
          r3y++;
        }
        break;
      case 6:
        r3y = 0;
        y = 0;
        while (y < width) {
          if (r3y === 3) {
            r3y = 0;
          }
          r3x = 0;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
            }
            if (!((x & y & 1) + (r3x && (r3x === r3y)) & 1) && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
          r3y++;
        }
        break;
      case 7:
        r3y = 0;
        y = 0;
        while (y < width) {
          if (r3y === 3) {
            r3y = 0;
          }
          r3x = 0;
          x = 0;
          while (x < width) {
            if (r3x === 3) {
              r3x = 0;
            }
            if (!((r3x && (r3x === r3y)) + ((x + y) & 1) & 1) && !ismasked(x, y)) {
              qrframe[x + y * width] ^= 1;
            }
            x++;
            r3x++;
          }
          y++;
          r3y++;
        }
    }
  };
  badruns = function(length) {
    var i, runsbad;
    i = void 0;
    runsbad = 0;
    i = 0;
    while (i <= length) {
      if (rlens[i] >= 5) {
        runsbad += N1 + rlens[i] - 5;
      }
      i++;
    }
    i = 3;
    while (i < length - 1) {
      if (rlens[i - 2] === rlens[i + 2] && rlens[i + 2] === rlens[i - 1] && rlens[i - 1] === rlens[i + 1] && rlens[i - 1] * 3 === rlens[i] && (rlens[i - 3] === 0 || i + 3 > length || rlens[i - 3] * 3 >= rlens[i] * 4 || rlens[i + 3] * 3 >= rlens[i] * 4)) {
        runsbad += N3;
      }
      i += 2;
    }
    return runsbad;
  };
  badcheck = function() {
    var b, b1, big, bw, count, h, thisbad, x, y;
    x = void 0;
    y = void 0;
    h = void 0;
    b = void 0;
    b1 = void 0;
    thisbad = 0;
    bw = 0;
    y = 0;
    while (y < width - 1) {
      x = 0;
      while (x < width - 1) {
        if ((qrframe[x + width * y] && qrframe[(x + 1) + width * y] && qrframe[x + width * (y + 1)] && qrframe[(x + 1) + width * (y + 1)]) || !(qrframe[x + width * y] || qrframe[(x + 1) + width * y] || qrframe[x + width * (y + 1)] || qrframe[(x + 1) + width * (y + 1)])) {
          thisbad += N2;
        }
        x++;
      }
      y++;
    }
    y = 0;
    while (y < width) {
      rlens[0] = 0;
      h = b = x = 0;
      while (x < width) {
        if ((b1 = qrframe[x + width * y]) === b) {
          rlens[h]++;
        } else {
          rlens[++h] = 1;
        }
        b = b1;
        bw += (b ? 1 : -1);
        x++;
      }
      thisbad += badruns(h);
      y++;
    }
    if (bw < 0) {
      bw = -bw;
    }
    big = bw;
    count = 0;
    big += big << 2;
    big <<= 1;
    while (big > width * width) {
      big -= width * width;
      count++;
    }
    thisbad += count * N4;
    x = 0;
    while (x < width) {
      rlens[0] = 0;
      h = b = y = 0;
      while (y < width) {
        if ((b1 = qrframe[x + width * y]) === b) {
          rlens[h]++;
        } else {
          rlens[++h] = 1;
        }
        b = b1;
        y++;
      }
      thisbad += badruns(h);
      x++;
    }
    return thisbad;
  };
  genframe = function(instring) {
    var datablkw, eccblkwid, i, j, k, m, neccblk1, neccblk2, qrframe, strinbuf, t, v, version, width, x, y;
    x = void 0;
    y = void 0;
    k = void 0;
    t = void 0;
    v = void 0;
    i = void 0;
    j = void 0;
    m = void 0;
    t = instring.length;
    version = 0;
    while (true) {
      version++;
      k = (ecclevel - 1) * 4 + (version - 1) * 16;
      neccblk1 = eccblocks[k++];
      neccblk2 = eccblocks[k++];
      datablkw = eccblocks[k++];
      eccblkwid = eccblocks[k];
      k = datablkw * (neccblk1 + neccblk2) + neccblk2 - 3 + (version <= 9);
      if (t <= k) {
        break;
      }
      if (!(version < 40)) {
        break;
      }
    }
    width = 17 + 4 * version;
    v = datablkw + (datablkw + eccblkwid) * (neccblk1 + neccblk2) + neccblk2;
    t = 0;
    while (t < v) {
      eccbuf[t] = 0;
      t++;
    }
    strinbuf = instring.slice(0);
    t = 0;
    while (t < width * width) {
      qrframe[t] = 0;
      t++;
    }
    t = 0;
    while (t < (width * (width + 1) + 1) / 2) {
      framask[t] = 0;
      t++;
    }
    t = 0;
    while (t < 3) {
      k = 0;
      y = 0;
      if (t === 1) {
        k = width - 7;
      }
      if (t === 2) {
        y = width - 7;
      }
      qrframe[(y + 3) + width * (k + 3)] = 1;
      x = 0;
      while (x < 6) {
        qrframe[(y + x) + width * k] = 1;
        qrframe[y + width * (k + x + 1)] = 1;
        qrframe[(y + 6) + width * (k + x)] = 1;
        qrframe[(y + x + 1) + width * (k + 6)] = 1;
        x++;
      }
      x = 1;
      while (x < 5) {
        setmask(y + x, k + 1);
        setmask(y + 1, k + x + 1);
        setmask(y + 5, k + x);
        setmask(y + x + 1, k + 5);
        x++;
      }
      x = 2;
      while (x < 4) {
        qrframe[(y + x) + width * (k + 2)] = 1;
        qrframe[(y + 2) + width * (k + x + 1)] = 1;
        qrframe[(y + 4) + width * (k + x)] = 1;
        qrframe[(y + x + 1) + width * (k + 4)] = 1;
        x++;
      }
      t++;
    }
    if (version > 1) {
      t = adelta[version];
      y = width - 7;
      while (true) {
        x = width - 7;
        while (x > t - 3) {
          putalign(x, y);
          if (x < t) {
            break;
          }
          x -= t;
        }
        if (y <= t + 9) {
          break;
        }
        y -= t;
        putalign(6, y);
        putalign(y, 6);
      }
    }
    qrframe[8 + width * (width - 8)] = 1;
    y = 0;
    while (y < 7) {
      setmask(7, y);
      setmask(width - 8, y);
      setmask(7, y + width - 7);
      y++;
    }
    x = 0;
    while (x < 8) {
      setmask(x, 7);
      setmask(x + width - 8, 7);
      setmask(x, width - 8);
      x++;
    }
    x = 0;
    while (x < 9) {
      setmask(x, 8);
      x++;
    }
    x = 0;
    while (x < 8) {
      setmask(x + width - 8, 8);
      setmask(8, x);
      x++;
    }
    y = 0;
    while (y < 7) {
      setmask(8, y + width - 7);
      y++;
    }
    x = 0;
    while (x < width - 14) {
      if (x & 1) {
        setmask(8 + x, 6);
        setmask(6, 8 + x);
      } else {
        qrframe[(8 + x) + width * 6] = 1;
        qrframe[6 + width * (8 + x)] = 1;
      }
      x++;
    }
    if (version > 6) {
      t = vpat[version - 7];
      k = 17;
      x = 0;
      while (x < 6) {
        y = 0;
        while (y < 3) {
          if (1 & (k > 11 ? version >> (k - 12) : t >> k)) {
            qrframe[(5 - x) + width * (2 - y + width - 11)] = 1;
            qrframe[(2 - y + width - 11) + width * (5 - x)] = 1;
          } else {
            setmask(5 - x, 2 - y + width - 11);
            setmask(2 - y + width - 11, 5 - x);
          }
          y++;
          k--;
        }
        x++;
      }
    }
    y = 0;
    while (y < width) {
      x = 0;
      while (x <= y) {
        if (qrframe[x + width * y]) {
          setmask(x, y);
        }
        x++;
      }
      y++;
    }
    v = strinbuf.length;
    i = 0;
    while (i < v) {
      eccbuf[i] = strinbuf.charCodeAt(i);
      i++;
    }
    strinbuf = eccbuf.slice(0);
    x = datablkw * (neccblk1 + neccblk2) + neccblk2;
    if (v >= x - 2) {
      v = x - 2;
      if (version > 9) {
        v--;
      }
    }
    i = v;
    if (version > 9) {
      strinbuf[i + 2] = 0;
      strinbuf[i + 3] = 0;
      while (i--) {
        t = strinbuf[i];
        strinbuf[i + 3] |= 255 & (t << 4);
        strinbuf[i + 2] = t >> 4;
      }
      strinbuf[2] |= 255 & (v << 4);
      strinbuf[1] = v >> 4;
      strinbuf[0] = 0x40 | (v >> 12);
    } else {
      strinbuf[i + 1] = 0;
      strinbuf[i + 2] = 0;
      while (i--) {
        t = strinbuf[i];
        strinbuf[i + 2] |= 255 & (t << 4);
        strinbuf[i + 1] = t >> 4;
      }
      strinbuf[1] |= 255 & (v << 4);
      strinbuf[0] = 0x40 | (v >> 4);
    }
    i = v + 3 - (version < 10);
    while (i < x) {
      strinbuf[i++] = 0xec;
      strinbuf[i++] = 0x11;
    }
    genpoly[0] = 1;
    i = 0;
    while (i < eccblkwid) {
      genpoly[i + 1] = 1;
      j = i;
      while (j > 0) {
        genpoly[j] = (genpoly[j] ? genpoly[j - 1] ^ gexp[modnn(glog[genpoly[j]] + i)] : genpoly[j - 1]);
        j--;
      }
      genpoly[0] = gexp[modnn(glog[genpoly[0]] + i)];
      i++;
    }
    i = 0;
    while (i <= eccblkwid) {
      genpoly[i] = glog[genpoly[i]];
      i++;
    }
    k = x;
    y = 0;
    i = 0;
    while (i < neccblk1) {
      appendrs(y, datablkw, k, eccblkwid);
      y += datablkw;
      k += eccblkwid;
      i++;
    }
    i = 0;
    while (i < neccblk2) {
      appendrs(y, datablkw + 1, k, eccblkwid);
      y += datablkw + 1;
      k += eccblkwid;
      i++;
    }
    y = 0;
    i = 0;
    while (i < datablkw) {
      j = 0;
      while (j < neccblk1) {
        eccbuf[y++] = strinbuf[i + j * datablkw];
        j++;
      }
      j = 0;
      while (j < neccblk2) {
        eccbuf[y++] = strinbuf[(neccblk1 * datablkw) + i + (j * (datablkw + 1))];
        j++;
      }
      i++;
    }
    j = 0;
    while (j < neccblk2) {
      eccbuf[y++] = strinbuf[(neccblk1 * datablkw) + i + (j * (datablkw + 1))];
      j++;
    }
    i = 0;
    while (i < eccblkwid) {
      j = 0;
      while (j < neccblk1 + neccblk2) {
        eccbuf[y++] = strinbuf[x + i + j * eccblkwid];
        j++;
      }
      i++;
    }
    strinbuf = eccbuf;
    x = y = width - 1;
    k = v = 1;
    m = (datablkw + eccblkwid) * (neccblk1 + neccblk2) + neccblk2;
    i = 0;
    while (i < m) {
      t = strinbuf[i];
      j = 0;
      while (j < 8) {
        if (0x80 & t) {
          qrframe[x + width * y] = 1;
        }
        while (true) {
          if (!v) {
            x++;
            if (k) {
              if (y === 0) {
                x -= 2;
                k = !k;
                if (x === 6) {
                  x--;
                  y = 9;
                }
              }
            } else {
              if (y === width - 1) {
                x -= 2;
                k = !k;
                if (x === 6) {
                  x--;
                  y -= 8;
                }
              }
            }
          }
          v = !v;
          if (!ismasked(x, y)) {
            break;
          }
        }
        j++;
        t <<= 1;
      }
      i++;
    }
    strinbuf = qrframe.slice(0);
    t = 0;
    y = 30000;
    k = 0;
    while (k < 8) {
      applymask(k);
      x = badcheck();
      if (x < y) {
        y = x;
        t = k;
      }
      if (t === 7) {
        break;
      }
      qrframe = strinbuf.slice(0);
      k++;
    }
    if (t !== k) {
      applymask(t);
    }
    y = fmtword[t + ((ecclevel - 1) << 3)];
    k = 0;
    while (k < 8) {
      if (y & 1) {
        qrframe[(width - 1 - k) + width * 8] = 1;
        if (k < 6) {
          qrframe[8 + width * k] = 1;
        } else {
          qrframe[8 + width * (k + 1)] = 1;
        }
      }
      k++;
      y >>= 1;
    }
    k = 0;
    while (k < 7) {
      if (y & 1) {
        qrframe[8 + width * (width - 7 + k)] = 1;
        if (k) {
          qrframe[(6 - k) + width * 8] = 1;
        } else {
          qrframe[7 + width * 8] = 1;
        }
      }
      k++;
      y >>= 1;
    }
    return qrframe;
  };
  adelta = [0, 11, 15, 19, 23, 27, 31, 16, 18, 20, 22, 24, 26, 28, 20, 22, 24, 24, 26, 28, 28, 22, 24, 24, 26, 26, 28, 28, 24, 24, 26, 26, 26, 28, 28, 24, 26, 26, 26, 28, 28];
  vpat = [0xc94, 0x5bc, 0xa99, 0x4d3, 0xbf6, 0x762, 0x847, 0x60d, 0x928, 0xb78, 0x45d, 0xa17, 0x532, 0x9a6, 0x683, 0x8c9, 0x7ec, 0xec4, 0x1e1, 0xfab, 0x08e, 0xc1a, 0x33f, 0xd75, 0x250, 0x9d5, 0x6f0, 0x8ba, 0x79f, 0xb0b, 0x42e, 0xa64, 0x541, 0xc69];
  fmtword = [0x77c4, 0x72f3, 0x7daa, 0x789d, 0x662f, 0x6318, 0x6c41, 0x6976, 0x5412, 0x5125, 0x5e7c, 0x5b4b, 0x45f9, 0x40ce, 0x4f97, 0x4aa0, 0x355f, 0x3068, 0x3f31, 0x3a06, 0x24b4, 0x2183, 0x2eda, 0x2bed, 0x1689, 0x13be, 0x1ce7, 0x19d0, 0x0762, 0x0255, 0x0d0c, 0x083b];
  eccblocks = [1, 0, 19, 7, 1, 0, 16, 10, 1, 0, 13, 13, 1, 0, 9, 17, 1, 0, 34, 10, 1, 0, 28, 16, 1, 0, 22, 22, 1, 0, 16, 28, 1, 0, 55, 15, 1, 0, 44, 26, 2, 0, 17, 18, 2, 0, 13, 22, 1, 0, 80, 20, 2, 0, 32, 18, 2, 0, 24, 26, 4, 0, 9, 16, 1, 0, 108, 26, 2, 0, 43, 24, 2, 2, 15, 18, 2, 2, 11, 22, 2, 0, 68, 18, 4, 0, 27, 16, 4, 0, 19, 24, 4, 0, 15, 28, 2, 0, 78, 20, 4, 0, 31, 18, 2, 4, 14, 18, 4, 1, 13, 26, 2, 0, 97, 24, 2, 2, 38, 22, 4, 2, 18, 22, 4, 2, 14, 26, 2, 0, 116, 30, 3, 2, 36, 22, 4, 4, 16, 20, 4, 4, 12, 24, 2, 2, 68, 18, 4, 1, 43, 26, 6, 2, 19, 24, 6, 2, 15, 28, 4, 0, 81, 20, 1, 4, 50, 30, 4, 4, 22, 28, 3, 8, 12, 24, 2, 2, 92, 24, 6, 2, 36, 22, 4, 6, 20, 26, 7, 4, 14, 28, 4, 0, 107, 26, 8, 1, 37, 22, 8, 4, 20, 24, 12, 4, 11, 22, 3, 1, 115, 30, 4, 5, 40, 24, 11, 5, 16, 20, 11, 5, 12, 24, 5, 1, 87, 22, 5, 5, 41, 24, 5, 7, 24, 30, 11, 7, 12, 24, 5, 1, 98, 24, 7, 3, 45, 28, 15, 2, 19, 24, 3, 13, 15, 30, 1, 5, 107, 28, 10, 1, 46, 28, 1, 15, 22, 28, 2, 17, 14, 28, 5, 1, 120, 30, 9, 4, 43, 26, 17, 1, 22, 28, 2, 19, 14, 28, 3, 4, 113, 28, 3, 11, 44, 26, 17, 4, 21, 26, 9, 16, 13, 26, 3, 5, 107, 28, 3, 13, 41, 26, 15, 5, 24, 30, 15, 10, 15, 28, 4, 4, 116, 28, 17, 0, 42, 26, 17, 6, 22, 28, 19, 6, 16, 30, 2, 7, 111, 28, 17, 0, 46, 28, 7, 16, 24, 30, 34, 0, 13, 24, 4, 5, 121, 30, 4, 14, 47, 28, 11, 14, 24, 30, 16, 14, 15, 30, 6, 4, 117, 30, 6, 14, 45, 28, 11, 16, 24, 30, 30, 2, 16, 30, 8, 4, 106, 26, 8, 13, 47, 28, 7, 22, 24, 30, 22, 13, 15, 30, 10, 2, 114, 28, 19, 4, 46, 28, 28, 6, 22, 28, 33, 4, 16, 30, 8, 4, 122, 30, 22, 3, 45, 28, 8, 26, 23, 30, 12, 28, 15, 30, 3, 10, 117, 30, 3, 23, 45, 28, 4, 31, 24, 30, 11, 31, 15, 30, 7, 7, 116, 30, 21, 7, 45, 28, 1, 37, 23, 30, 19, 26, 15, 30, 5, 10, 115, 30, 19, 10, 47, 28, 15, 25, 24, 30, 23, 25, 15, 30, 13, 3, 115, 30, 2, 29, 46, 28, 42, 1, 24, 30, 23, 28, 15, 30, 17, 0, 115, 30, 10, 23, 46, 28, 10, 35, 24, 30, 19, 35, 15, 30, 17, 1, 115, 30, 14, 21, 46, 28, 29, 19, 24, 30, 11, 46, 15, 30, 13, 6, 115, 30, 14, 23, 46, 28, 44, 7, 24, 30, 59, 1, 16, 30, 12, 7, 121, 30, 12, 26, 47, 28, 39, 14, 24, 30, 22, 41, 15, 30, 6, 14, 121, 30, 6, 34, 47, 28, 46, 10, 24, 30, 2, 64, 15, 30, 17, 4, 122, 30, 29, 14, 46, 28, 49, 10, 24, 30, 24, 46, 15, 30, 4, 18, 122, 30, 13, 32, 46, 28, 48, 14, 24, 30, 42, 32, 15, 30, 20, 4, 117, 30, 40, 7, 47, 28, 43, 22, 24, 30, 10, 67, 15, 30, 19, 6, 118, 30, 18, 31, 47, 28, 34, 34, 24, 30, 20, 61, 15, 30];
  glog = [0xff, 0x00, 0x01, 0x19, 0x02, 0x32, 0x1a, 0xc6, 0x03, 0xdf, 0x33, 0xee, 0x1b, 0x68, 0xc7, 0x4b, 0x04, 0x64, 0xe0, 0x0e, 0x34, 0x8d, 0xef, 0x81, 0x1c, 0xc1, 0x69, 0xf8, 0xc8, 0x08, 0x4c, 0x71, 0x05, 0x8a, 0x65, 0x2f, 0xe1, 0x24, 0x0f, 0x21, 0x35, 0x93, 0x8e, 0xda, 0xf0, 0x12, 0x82, 0x45, 0x1d, 0xb5, 0xc2, 0x7d, 0x6a, 0x27, 0xf9, 0xb9, 0xc9, 0x9a, 0x09, 0x78, 0x4d, 0xe4, 0x72, 0xa6, 0x06, 0xbf, 0x8b, 0x62, 0x66, 0xdd, 0x30, 0xfd, 0xe2, 0x98, 0x25, 0xb3, 0x10, 0x91, 0x22, 0x88, 0x36, 0xd0, 0x94, 0xce, 0x8f, 0x96, 0xdb, 0xbd, 0xf1, 0xd2, 0x13, 0x5c, 0x83, 0x38, 0x46, 0x40, 0x1e, 0x42, 0xb6, 0xa3, 0xc3, 0x48, 0x7e, 0x6e, 0x6b, 0x3a, 0x28, 0x54, 0xfa, 0x85, 0xba, 0x3d, 0xca, 0x5e, 0x9b, 0x9f, 0x0a, 0x15, 0x79, 0x2b, 0x4e, 0xd4, 0xe5, 0xac, 0x73, 0xf3, 0xa7, 0x57, 0x07, 0x70, 0xc0, 0xf7, 0x8c, 0x80, 0x63, 0x0d, 0x67, 0x4a, 0xde, 0xed, 0x31, 0xc5, 0xfe, 0x18, 0xe3, 0xa5, 0x99, 0x77, 0x26, 0xb8, 0xb4, 0x7c, 0x11, 0x44, 0x92, 0xd9, 0x23, 0x20, 0x89, 0x2e, 0x37, 0x3f, 0xd1, 0x5b, 0x95, 0xbc, 0xcf, 0xcd, 0x90, 0x87, 0x97, 0xb2, 0xdc, 0xfc, 0xbe, 0x61, 0xf2, 0x56, 0xd3, 0xab, 0x14, 0x2a, 0x5d, 0x9e, 0x84, 0x3c, 0x39, 0x53, 0x47, 0x6d, 0x41, 0xa2, 0x1f, 0x2d, 0x43, 0xd8, 0xb7, 0x7b, 0xa4, 0x76, 0xc4, 0x17, 0x49, 0xec, 0x7f, 0x0c, 0x6f, 0xf6, 0x6c, 0xa1, 0x3b, 0x52, 0x29, 0x9d, 0x55, 0xaa, 0xfb, 0x60, 0x86, 0xb1, 0xbb, 0xcc, 0x3e, 0x5a, 0xcb, 0x59, 0x5f, 0xb0, 0x9c, 0xa9, 0xa0, 0x51, 0x0b, 0xf5, 0x16, 0xeb, 0x7a, 0x75, 0x2c, 0xd7, 0x4f, 0xae, 0xd5, 0xe9, 0xe6, 0xe7, 0xad, 0xe8, 0x74, 0xd6, 0xf4, 0xea, 0xa8, 0x50, 0x58, 0xaf];
  gexp = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1d, 0x3a, 0x74, 0xe8, 0xcd, 0x87, 0x13, 0x26, 0x4c, 0x98, 0x2d, 0x5a, 0xb4, 0x75, 0xea, 0xc9, 0x8f, 0x03, 0x06, 0x0c, 0x18, 0x30, 0x60, 0xc0, 0x9d, 0x27, 0x4e, 0x9c, 0x25, 0x4a, 0x94, 0x35, 0x6a, 0xd4, 0xb5, 0x77, 0xee, 0xc1, 0x9f, 0x23, 0x46, 0x8c, 0x05, 0x0a, 0x14, 0x28, 0x50, 0xa0, 0x5d, 0xba, 0x69, 0xd2, 0xb9, 0x6f, 0xde, 0xa1, 0x5f, 0xbe, 0x61, 0xc2, 0x99, 0x2f, 0x5e, 0xbc, 0x65, 0xca, 0x89, 0x0f, 0x1e, 0x3c, 0x78, 0xf0, 0xfd, 0xe7, 0xd3, 0xbb, 0x6b, 0xd6, 0xb1, 0x7f, 0xfe, 0xe1, 0xdf, 0xa3, 0x5b, 0xb6, 0x71, 0xe2, 0xd9, 0xaf, 0x43, 0x86, 0x11, 0x22, 0x44, 0x88, 0x0d, 0x1a, 0x34, 0x68, 0xd0, 0xbd, 0x67, 0xce, 0x81, 0x1f, 0x3e, 0x7c, 0xf8, 0xed, 0xc7, 0x93, 0x3b, 0x76, 0xec, 0xc5, 0x97, 0x33, 0x66, 0xcc, 0x85, 0x17, 0x2e, 0x5c, 0xb8, 0x6d, 0xda, 0xa9, 0x4f, 0x9e, 0x21, 0x42, 0x84, 0x15, 0x2a, 0x54, 0xa8, 0x4d, 0x9a, 0x29, 0x52, 0xa4, 0x55, 0xaa, 0x49, 0x92, 0x39, 0x72, 0xe4, 0xd5, 0xb7, 0x73, 0xe6, 0xd1, 0xbf, 0x63, 0xc6, 0x91, 0x3f, 0x7e, 0xfc, 0xe5, 0xd7, 0xb3, 0x7b, 0xf6, 0xf1, 0xff, 0xe3, 0xdb, 0xab, 0x4b, 0x96, 0x31, 0x62, 0xc4, 0x95, 0x37, 0x6e, 0xdc, 0xa5, 0x57, 0xae, 0x41, 0x82, 0x19, 0x32, 0x64, 0xc8, 0x8d, 0x07, 0x0e, 0x1c, 0x38, 0x70, 0xe0, 0xdd, 0xa7, 0x53, 0xa6, 0x51, 0xa2, 0x59, 0xb2, 0x79, 0xf2, 0xf9, 0xef, 0xc3, 0x9b, 0x2b, 0x56, 0xac, 0x45, 0x8a, 0x09, 0x12, 0x24, 0x48, 0x90, 0x3d, 0x7a, 0xf4, 0xf5, 0xf7, 0xf3, 0xfb, 0xeb, 0xcb, 0x8b, 0x0b, 0x16, 0x2c, 0x58, 0xb0, 0x7d, 0xfa, 0xe9, 0xcf, 0x83, 0x1b, 0x36, 0x6c, 0xd8, 0xad, 0x47, 0x8e, 0x00];
  strinbuf = [];
  eccbuf = [];
  qrframe = [];
  framask = [];
  rlens = [];
  version = void 0;
  width = void 0;
  neccblk1 = void 0;
  neccblk2 = void 0;
  datablkw = void 0;
  eccblkwid = void 0;
  ecclevel = 1;
  genpoly = [];
  N1 = 3;
  N2 = 3;
  N3 = 40;
  N4 = 10;
  wd = void 0;
  ht = void 0;
  qrc = void 0;
  /*
   * 
   * Modal Handling Functions
   * 
   * show tooltip, can be used on any element with jquery
   * 
   * 
  */
  $.fn.showTooltip = function(options) {
    var settings;
    settings = {
      position: 'below'
    };
    return this.each(function(i) {
      var $t, data, offset, toRemove, tooltip, _i, _len;
      if (options) {
        $.extend(settings, options);
      }
      $t = $(this);
      offset = $t.offset();
      data = $t.data('tooltips');
      if (!data) {
        data = [];
      }
      if (settings.message) {
        tooltip = $('<div class="tooltip" />');
        tooltip.html(settings.message);
        tooltip.css({
          left: offset.left,
          top: offset.top + (settings.position === 'below' ? $t.height() + 40 : 0)
        });
        $('body').append(tooltip);
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          i = data[_i];
          i.stop(true, true).fadeOut();
        }
        data.push(tooltip);
        if (data.length > 5) {
          toRemove = data.shift();
          toRemove.remove();
        }
        $t.data('tooltips', data);
      } else {
        tooltip = data[data.length - 1];
      }
      /*
      
              TODO : Make the animation in a custom slide up / slide down thing with $.animate
      
          */
      return tooltip.stop(true, true).fadeIn().delay(usualDelay).fadeOut();
    });
  };
  /*
     * 
     * Modal Handling Functions
     * 
     * Basic load
     * 
     * 
  */
  loadModal = function(options, next) {
    var $body, buttons, close, height, i, modal, myNext, resizeEvent, scrollbarWidth, settings, thisButton, win, _i, _len, _ref;
    scrollbarWidth = $.scrollbarWidth();
    modal = $('<div class="modal" />');
    win = $('<div class="window" />');
    close = $('<div class="close" />');
    settings = {
      width: 500,
      height: 235,
      closeText: 'close'
    };
    if (options) {
      $.extend(settings, options);
    }
    myNext = function() {
      $window.unbind('scroll resize', resizeEvent);
      $window.unbind('resize', resizeEvent);
      $body.css({
        overflow: 'inherit',
        'padding-right': 0
      });
      modal.fadeOut(function() {
        return modal.remove();
      });
      close.fadeOut(function() {
        return close.remove();
      });
      return win.fadeOut(function() {
        win.remove();
        if ($('.window').length === 0) {
          return $('#container').show();
        }
      });
    };
    if (settings.closeText) {
      close.html(settings.closeText);
    }
    if (settings.content) {
      win.html(settings.content);
    }
    if (settings.height) {
      win.css({
        'min-height': settings.height
      });
    }
    if (settings.width) {
      win.width(settings.width);
    }
    buttons = $('<div class="buttons" />');
    /*
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
      */
    if (settings.buttons) {
      _ref = settings.buttons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        thisButton = $('<input type="button" class="button" value="' + i.label + '" class="submit">');
        if (i["class"]) {
          thisButton.addClass(i["class"]);
        } else {
          thisButton.addClass('normal');
        }
        thisButton.click(function() {
          return i.action(myNext);
        });
        buttons.append(thisButton);
      }
    }
    win.append(buttons);
    $('body').append(modal, close, win);
    $body = $('body');
    resizeEvent = function() {
      var height, top;
      width = $window.width();
      height = $window.height();
      if (width < settings.width || height < win.height()) {
        $window.unbind('scroll resize', resizeEvent);
        close.css({
          position: 'relative'
        });
        win.width(width - 60).css({
          position: 'relative'
        });
        $('#container').hide();
        top = close.offset().top;
        modal.css({
          top: 0,
          left: 0,
          width: width,
          height: top
        });
        return window.scroll(0, top);
      } else {
        $body.css({
          overflow: 'hidden',
          'padding-right': scrollbarWidth
        });
        win.position({
          of: $window,
          at: 'center center',
          my: 'center center',
          offset: '0 40px'
        });
        modal.position({
          of: $window,
          at: 'center center'
        });
        return close.position({
          of: win,
          at: 'right top',
          my: 'right bottom',
          offset: '0 0'
        });
      }
    };
    $window.bind('resize scroll', resizeEvent);
    modal.click(myNext);
    close.click(myNext);
    width = $window.width();
    height = $window.height();
    if (width < settings.width || height < win.height()) {
      modal.show();
      win.show();
      close.show();
    } else {
      modal.fadeIn();
      win.fadeIn();
      close.fadeIn();
    }
    if (next) {
      next(myNext);
    }
    return resizeEvent();
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Loading (Subclass of loadmodal)
   * 
   * 
  */
  loadLoading = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    modifiedOptions = {
      content: 'Loading ... ',
      height: 100,
      width: 200
    };
    for (i in options) {
      v = options[i];
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Confirm (Subclass of loadmodal)
   * like javascript confirm()
   * 
  */
  loadConfirm = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    modifiedOptions = {
      content: 'Confirm',
      height: 80,
      width: 300
    };
    for (i in options) {
      v = options[i];
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Alert (Subclass of loadmodal)
   * like javascript alert()
   * 
  */
  loadAlert = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    next = next || function() {};
    if (typeof options === 'string') {
      options = {
        content: options
      };
    }
    modifiedOptions = {
      content: 'Alert',
      buttons: [
        {
          action: function(close) {
            return close();
          },
          label: 'Ok'
        }
      ],
      height: 80,
      width: 300
    };
    for (i in options) {
      v = options[i];
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * jQuery Scrollbar Width v1.0
   * 
   * Copyright 2011, Rasmus Schultz
   * Licensed under LGPL v3.0
   * http:#www.gnu.org/licenses/lgpl-3.0.txt
  */
  $.scrollbarWidth = function() {
    var $body, w;
    if (!$._scrollbarWidth) {
      $body = $('body');
      w = $body.css('overflow', 'hidden').width();
      $body.css('overflow', 'scroll');
      w -= $body.width();
      if (!w) {
        w = $body.width() - $body[0].clientWidth;
      }
      $body.css('overflow', '');
      $._scrollbarWidth = w;
    }
    return $._scrollbarWidth;
  };
  /*
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
  */
  dateFormat = (function() {
    var pad, timezone, timezoneClip, token;
    function dateFormat() {}
    token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g;
    timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g;
    timezoneClip = /[^-+\dA-Z]/g;
    pad = function(val, len) {
      val = String(val);
      len = len || 2;
      while (val.length < len) {
        val = "0" + val;
      }
      return val;
    };
    dateFormat.prototype.format = function(date, mask, utc) {
      var D, H, L, M, d, dF, flags, m, o, s, y, _;
      dF = dateFormat.prototype;
      if (arguments.length === 1 && Object.prototype.toString.call(date) === "[object String]" && !/\d/.test(date)) {
        mask = date;
        date = void 0;
      }
      date = date ? new Date(date) : new Date;
      if (isNaN(date)) {
        throw SyntaxError("invalid date");
      }
      mask = String(dF.masks[mask] || mask || dF.masks["default"]);
      if (mask.slice(0, 4) === "UTC:") {
        mask = mask.slice(4);
        utc = true;
      }
      _ = utc ? "getUTC" : "get";
      d = date[_ + "Date"]();
      D = date[_ + "Day"]();
      m = date[_ + "Month"]();
      y = date[_ + "FullYear"]();
      H = date[_ + "Hours"]();
      M = date[_ + "Minutes"]();
      s = date[_ + "Seconds"]();
      L = date[_ + "Milliseconds"]();
      o = utc != null ? utc : {
        0: date.getTimezoneOffset()
      };
      flags = {
        d: d,
        dd: pad(d),
        ddd: dF.i18n.dayNames[D],
        dddd: dF.i18n.dayNames[D + 7],
        m: m + 1,
        mm: pad(m + 1),
        mmm: dF.i18n.monthNames[m],
        mmmm: dF.i18n.monthNames[m + 12],
        yy: String(y).slice(2),
        yyyy: y,
        h: H % 12 || 12,
        hh: pad(H % 12 || 12),
        H: H,
        HH: pad(H),
        M: M,
        MM: pad(M),
        s: s,
        ss: pad(s),
        l: pad(L, 3),
        L: pad(L > 99 ? Math.round(L / 10) : L),
        t: H < 12 ? "a" : "p",
        tt: H < 12 ? "am" : "pm",
        T: H < 12 ? "A" : "P",
        TT: H < 12 ? "AM" : "PM",
        Z: utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
        o: (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
        S: ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 !== 10) * d % 10]
      };
      return mask.replace(token, function($0) {
        if (flags) {
          return flags[$0];
        } else {
          return $0.slice(1, $0.length - 1);
        }
      });
    };
    dateFormat.prototype.masks = {
      "default": "ddd mmm dd yyyy HH:MM:ss",
      shortDate: "m/d/yy",
      mediumDate: "mmm d, yyyy",
      longDate: "mmmm d, yyyy",
      fullDate: "dddd, mmmm d, yyyy",
      shortTime: "h:MM TT",
      mediumTime: "h:MM:ss TT",
      longTime: "h:MM:ss TT Z",
      isoDate: "yyyy-mm-dd",
      isoTime: "HH:MM:ss",
      isoDateTime: "yyyy-mm-dd'T'HH:MM:ss",
      isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
    };
    dateFormat.prototype.i18n = {
      dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    };
    return dateFormat;
  })();
  Date.prototype.format = function(mask, utc) {
    var a;
    a = new dateFormat;
    return a.format(this, mask, utc);
  };
  /*
   * jQuery Cookie plugin
   *
   * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
   * Dual licensed under the MIT and GPL licenses:
   * http://www.opensource.org/licenses/mit-license.php
   * http://www.gnu.org/licenses/gpl.html
   *
  */
  jQuery.cookie = function(key, value, options) {
    var days, decode, result, t;
    if (arguments.length > 1 && String(value) !== "[object Object]") {
      options = jQuery.extend({}, options);
      if (value === null || value === void 0) {
        options.expires = -1;
      }
      if (typeof options.expires === 'number') {
        days = options.expires;
        t = options.expires = new Date();
        t.setDate(t.getDate() + days);
      }
      value = String(value);
      document.cookie = [encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value), options.expires ? '; expires=' + options.expires.toUTCString() : '', options.path ? '; path=' + options.path : 'path=/', options.domain ? '; domain=' + options.domain : '', options.secure ? '; secure' : ''].join('');
    }
    options = value || {};
    decode = options.raw ? function(s) {
      return s;
    } : decodeURIComponent;
    if ((result = new RegExp('(?:^| )' + encodeURIComponent(key) + '=([^]*)').exec(document.cookie))) {
      return decode(result[1]);
    } else {
      return null;
    }
  };
  $.fn.box_rotate = function(options) {
    var settings;
    settings = {
      position: 'below'
    };
    return this.each(function(i) {
      var $t, degrees, rotate;
      if (options) {
        $.extend(settings, options);
      }
      $t = $(this);
      degrees = settings.degrees;
      rotate = Math.floor((degrees / 360) * 100) / 100;
      return $t.css({
        '-moz-transform': 'rotate(' + degrees + 'deg)',
        '-webkit-transform': 'rotate(' + degrees + 'deg)',
        '-o-transform': 'rotate(' + degrees + 'deg)',
        '-ms-transform': 'rotate(' + degrees + 'deg)',
        'filter:progid': 'DXImageTransform.Microsoft.BasicImage(rotation=' + rotate + ')'
      });
    });
  };
  /*
  
  
  THIS IS WHERE REAL CODE STARTS
  
  The 
  $ ->
  
    Means everything under him (like me, indented here)
    WILL be done on document ready event.
  
  
  
  */
  $(function() {
    /*
      Profile MENU in the TOP RIGHT
      Thing that shows a drop down
      */
    var $a, $am, $body, $card, $cat, $color1, $color2, $dForm, $designer, $feedback_a, $font_color, $font_family, $fonts, $gs, $lines, $mc, $notfonts, $qr, $slides, $upload, $win, active_theme, advanceSlide, card_height, card_inner_height, card_inner_width, card_width, closeMenu, d, default_theme, elem, execute_save, expandMenu, fam, font_families, getPosition, hasHidden, i, item_name, loadTheme, marginIncrement, maxSlides, monitorForComplete, newMargin, noTheme, pageTimer, path, qf, setPageTimer, shiftAmount, successfulLogin, timer, unfocus_highlight, updateCards, update_family, winH, _i, _j, _len, _len2;
    $a = $('.account-link');
    $am = $a.find('.account-menu');
    $body = $(document);
    $('.small-nav li').hover(function() {
      return $(this).addClass('hover');
    }, function() {
      return $(this).removeClass('hover');
    });
    closeMenu = function(e) {
      var $t;
      $t = $(e.target);
      if ($t.closest('.account-link').length) {
        $a = $t.closest('li').find('a');
        document.location.href = $a.attr('href');
      } else {
        $a.removeClass('click');
        $am.slideUp();
        $a.one('click', expandMenu);
        $body.unbind('click', closeMenu);
      }
      return false;
    };
    expandMenu = function() {
      $am.slideDown();
      $a.addClass('click');
      $body.bind('click', closeMenu);
      return false;
    };
    $a.one('click', expandMenu);
    /*
      Multiple
      Lines Of
      Comments
      */
    path = document.location.href.replace(/http:\/\/[^\/]*/ig, '');
    $('.design-button').click(function() {
      if (path !== '/') {
        document.location.href = '/#design-button';
      } else {
        $('html,body').animate({
          scrollTop: $('.section:eq(1)').offset().top
        }, 500);
      }
      return false;
    });
    if (path === '/#design-button') {
      document.location.href = '#';
      $('.design-button').click();
    }
    /*
      
      All the stuff for the admin template designer
      is probably going to be in this section right here.
    
      ok.
    
      */
    if (path === '/admin') {
      $designer = $('.designer');
      $card = $designer.find('.card');
      $qr = $card.find('.qr');
      $lines = $card.find('.line');
      $body = $(document);
      $cat = $designer.find('.category-field input');
      $color1 = $designer.find('.color1');
      $color2 = $designer.find('.color2');
      $notfonts = $designer.find('.not-font-style');
      $fonts = $designer.find('.font-style');
      $font_color = $fonts.find('.color');
      $font_family = $fonts.find('.font-family');
      $dForm = $designer.find('form');
      $upload = $dForm.find('[type=file]');
      card_height = $card.outerHeight();
      card_width = $card.outerWidth();
      card_inner_height = $card.height();
      card_inner_width = $card.width();
      active_theme = false;
      /*
          GOOGLE FONTS
      
          1. Load them
          2. Make their common names available
      
          */
      setTimeout(function() {
        return WebFont.load({
          google: {
            families: ["IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin"]
          }
        });
      }, 3000);
      font_families = ['Arial', 'Comic Sans MS', 'Courier New', 'Georgia', 'Impact', 'Times New Roman', 'Trebuchet MS', 'Verdana', 'IM Fell English SC', 'Julee', 'Syncopate', 'Gravitas One', 'Quicksand', 'Vast Shadow', 'Smokum', 'Ovo', 'Amatic SC', 'Rancho', 'Poly', 'Chivo', 'Prata', 'Abril Fatface', 'Ultra', 'Love Ya Like A Sister', 'Carter One', 'Luckiest Guy', 'Gruppo', 'Slackey'].sort();
      /*
          END GOOGLE FONTS
          */
      $font_family.find('option').remove();
      for (_i = 0, _len = font_families.length; _i < _len; _i++) {
        fam = font_families[_i];
        $font_family.append('<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>');
      }
      $qr.hide();
      $lines.hide();
      ht = 500;
      wd = 500;
      console.log(wd, ht);
      $qr.html('<canvas class="canvas" />');
      elem = $qr.find('.canvas')[0];
      qrc = elem.getContext("2d");
      qrc.canvas.width = wd;
      qrc.canvas.height = ht;
      d = document;
      ecclevel = 1;
      qf = genframe('http://cards.ly/fdasfs');
      /*
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
          */
      shiftAmount = 1;
      $body.keydown(function(e) {
        var $active_item, bottom_bound, c, new_left, new_top, top_bound;
        $active_item = $card.find('.active');
        c = e.keyCode;
        if ($active_item.length) {
          if (e.keyCode === 16) {
            shiftAmount = 10;
          }
          if (c === 38 || c === 40) {
            new_top = parseInt($active_item.css('top'));
            if (c === 38) {
              new_top -= shiftAmount;
            }
            if (c === 40) {
              new_top += shiftAmount;
            }
            top_bound = (card_height - card_inner_height) / 2;
            bottom_bound = top_bound + card_inner_height - $active_item.outerHeight();
            if (new_top < top_bound) {
              new_top = top_bound;
            }
            if (new_top > bottom_bound) {
              new_top = bottom_bound;
            }
            $active_item.css('top', new_top);
          }
          if (c === 37 || c === 39) {
            new_left = parseInt($active_item.css('left'));
            if (c === 37) {
              new_left -= shiftAmount;
            }
            if (c === 39) {
              new_left += shiftAmount;
            }
            top_bound = (card_width - card_inner_width) / 2;
            bottom_bound = top_bound + card_inner_width - $active_item.outerWidth();
            if (new_left < top_bound) {
              new_left = top_bound;
            }
            if (new_left > bottom_bound) {
              new_left = bottom_bound;
            }
            $active_item.css('left', new_left);
          }
          if (c === 38 || c === 40 || c === 39 || c === 37) {
            return false;
          }
        }
      });
      $body.keyup(function(e) {
        if (e.keyCode === 16) {
          return shiftAmount = 1;
        }
      });
      update_family = function() {
        var $active_item, $t, index;
        console.log(1);
        $t = $(this);
        $active_item = $card.find('.active');
        $active_item.css({
          'font-family': $t.val()
        });
        index = $active_item.prevAll().length;
        return active_theme.positions[index + 1].font_family = $t.val();
      };
      $font_family.change(update_family);
      $font_color.ColorPicker({
        livePreview: true,
        onChange: function(hsb, hex, rgb) {
          $font_color.val(hex);
          return $font_color.keyup();
        }
      });
      $font_color.keyup(function() {
        var $active_item, $t, index;
        $t = $(this);
        $active_item = $card.find('.active');
        $active_item.css({
          color: '#' + $t.val()
        });
        index = $active_item.prevAll().length;
        return active_theme.positions[index + 1].color = $t.val();
      });
      unfocus_highlight = function(e) {
        var $t;
        $t = $(e.target);
        if ($t.hasClass('font-style') || $t.closest('.font-style').length || $t.hasClass('line') || $t.hasClass('qr') || $t.closest('.line').length || $t.closest('.qr').length || $t.closest('.colorpicker').length) {
          return $t = null;
        } else {
          $card.find('.active').removeClass('active');
          $body.unbind('click', unfocus_highlight);
          $fonts.stop(true, false).slideUp();
          $notfonts.stop(true, false).slideDown();
          return false;
        }
      };
      $lines.mousedown(function() {
        var $pa, $t, index;
        $t = $(this);
        $pa = $card.find('.active');
        $pa.removeClass('active');
        $t.addClass('active');
        $body.bind('click', unfocus_highlight);
        index = $t.prevAll().length;
        $fonts.stop(true, false).slideDown();
        $notfonts.stop(true, false).slideUp();
        $font_color.val(active_theme.positions[index + 1].color);
        return $font_family.find('option[value="' + active_theme.positions[index + 1].font_family + '"]').attr('selected', 'selected');
      });
      $qr.mousedown(function() {
        var $pa, $t;
        $t = $(this);
        $pa = $card.find('.active');
        $pa.removeClass('active');
        $t.addClass('active');
        $body.bind('click', unfocus_highlight);
        $fonts.stop(true, false).slideUp();
        return $notfonts.stop(true, false).slideDown();
      });
      pageTimer = 0;
      setPageTimer = function() {
        clearTimeout(pageTimer);
        return pageTimer = setTimeout(function() {
          return execute_save();
        }, 500);
      };
      $cat.keyup(setPageTimer);
      $font_color.keyup(setPageTimer);
      $color1.keyup(setPageTimer);
      $color2.keyup(setPageTimer);
      $lines.draggable({
        grid: [10, 10],
        containment: '.designer .card',
        stop: setPageTimer
      });
      $lines.resizable({
        grid: 10,
        handles: 'n, e, s, w, se',
        resize: function(e, ui) {
          return $(ui.element).css({
            'font-size': ui.size.height + 'px',
            'line-height': ui.size.height + 'px'
          });
        },
        stop: setPageTimer
      });
      $qr.draggable({
        grid: [5, 5],
        containment: '.designer .card',
        stop: setPageTimer
      });
      $qr.resizable({
        grid: 5,
        containment: '.designer .card',
        handles: 'n, e, s, w, ne, nw, se, sw',
        aspectRatio: 1,
        stop: setPageTimer
      });
      $upload.change(function() {
        return $dForm.submit();
      });
      $('.theme-1,.theme-2').click(function() {
        var $c, $t;
        $t = $(this);
        $c = $t.closest('.card');
        $c.click();
        $('.theme-1,.theme-2').removeClass('active');
        $t.addClass('active');
        return false;
      });
      getPosition = function($t) {
        var height, left, result, top;
        height = parseInt($t.height());
        width = parseInt($t.width());
        left = parseInt($t.css('left'));
        top = parseInt($t.css('top'));
        if (isNaN(height) || isNaN(width) || isNaN(top) || isNaN(left)) {
          return false;
        }
        return result = {
          h: Math.round(height / card_height * 10000) / 100,
          w: Math.round(width / card_width * 10000) / 100,
          x: Math.round(left / card_width * 10000) / 100,
          y: Math.round(top / card_height * 10000) / 100
        };
      };
      execute_save = function(next) {
        var parameters, theme;
        theme = {
          _id: active_theme._id,
          category: $cat.val(),
          positions: [],
          color1: $color1.val(),
          color2: $color2.val(),
          s3_id: active_theme.s3_id
        };
        theme.positions.push(getPosition($qr));
        $lines.each(function() {
          var $t, pos;
          $t = $(this);
          pos = getPosition($t);
          if (pos) {
            return theme.positions.push(pos);
          }
        });
        parameters = {
          theme: theme,
          do_save: next ? true : false
        };
        return $.ajax({
          url: '/saveTheme',
          data: JSON.stringify(parameters),
          success: function(serverResponse) {
            if (!serverResponse.success) {
              $designer.find('.save').showTooltip({
                message: 'Error saving.'
              });
            }
            if (next) {
              return next();
            }
          },
          error: function() {
            $designer.find('.save').showTooltip({
              message: 'Error saving.'
            });
            if (next) {
              return next();
            }
          }
        });
      };
      $.s3_result = function(s3_id) {
        if (!noTheme() && s3_id) {
          active_theme.s3_id = s3_id;
          return $card.css({
            background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
          });
        } else {
          return loadAlert({
            content: 'I had trouble saving that image, please try again later.'
          });
        }
      };
      noTheme = function() {
        if (!active_theme) {
          loadAlert({
            content: 'Please create or select a theme first'
          });
          return true;
        } else {
          return false;
        }
      };
      default_theme = {
        category: '',
        color1: 'FFFFFF',
        color2: '000000',
        s3_id: '',
        positions: [
          {
            h: 45,
            w: 45,
            x: 70,
            y: 40
          }
        ]
      };
      for (i = 0; i <= 5; i++) {
        default_theme.positions.push({
          color: '000000',
          font_family: 'Vast Shadow',
          h: 7,
          w: 50,
          x: 5,
          y: 5 + i * 10
        });
      }
      loadTheme = function(theme) {
        var $li, i, pos, qr, _len2, _ref;
        active_theme = theme;
        qr = theme.positions.shift();
        $qr.show().css({
          top: qr.y / 100 * card_height,
          left: qr.x / 100 * card_width,
          height: qr.h / 100 * card_height,
          width: qr.w / 100 * card_height
        });
        _ref = theme.positions;
        for (i = 0, _len2 = _ref.length; i < _len2; i++) {
          pos = _ref[i];
          $li = $lines.eq(i);
          $li.show().css({
            top: pos.y / 100 * card_height,
            left: pos.x / 100 * card_width,
            width: (pos.w / 100 * card_width) + 'px',
            fontSize: (pos.h / 100 * card_height) + 'px',
            lineHeight: (pos.h / 100 * card_height) + 'px',
            fontFamily: pos.font_family,
            color: '#' + pos.color
          });
        }
        theme.positions.unshift(qr);
        $cat.val(theme.category);
        $color1.val(theme.color1);
        return $color2.val(theme.color2);
      };
      $('.add-new').click(function() {
        return loadTheme(default_theme);
        /*
              $new_li = $ '<li class="card" />'
              $('.category[category=""] .gallery').append $new_li
              $new_li.click()
              */
      });
      $designer.find('.buttons .save').click(function() {
        if (noTheme()) {
          return false;
        }
        return loadLoading({}, function(closeLoading) {
          return execute_save(function() {
            return closeLoading();
          });
        });
      });
      $designer.find('.buttons .delete').click(function() {
        if (noTheme()) {
          return false;
        }
        return loadModal({
          content: '<p>Are you sure you want to permanently delete this template?</p>',
          height: 160,
          width: 440,
          buttons: [
            {
              label: 'Delete',
              action: function(closeFunc) {
                /*
                            TODO: Make this delete the template
                
                            So send to the server to delete the template we're on here ...
                
                            */                return closeFunc();
              }
            }, {
              "class": 'gray',
              label: 'Cancel',
              action: function(closeFunc) {
                return closeFunc();
              }
            }
          ]
        });
      });
    }
    successfulLogin = function() {
      var $s;
      if (path === '/login') {
        return document.location.href = '/admin';
      } else {
        $s = $('.signins');
        $s.fadeOut(500, function() {
          $s.html('You are now logged in, please continue.');
          return $s.fadeIn(1000);
        });
        return $('.login a').attr('href', '/logout').html('Logout');
      }
    };
    $win = $(window);
    $mc = $('.main.card');
    winH = $win.height() + $win.scrollTop();
    hasHidden = [];
    $('.section-to-hide').each(function() {
      var $this, thisT;
      $this = $(this);
      thisT = $this.offset().top;
      if (winH < thisT) {
        return hasHidden.push({
          $this: $this,
          thisT: thisT
        });
      }
    });
    for (_j = 0, _len2 = hasHidden.length; _j < _len2; _j++) {
      i = hasHidden[_j];
      i.$this.hide();
    }
    /*
      Update Cards
    
      This is used each time we need to update all the cards on the home page with the new content that's typed in.
      */
    updateCards = function(rowNumber, value) {
      return $('.card .content').each(function() {
        return $(this).find('li:eq(' + rowNumber + ')').html(value);
      });
    };
    $win.scroll(function() {
      var i, newWinH, timeLapse, _k, _len3, _results;
      newWinH = $win.height() + $win.scrollTop();
      if ($mc.length) {
        if ($mc.offset().top + $mc.height() < newWinH && !$mc.data('didLoad')) {
          $mc.data('didLoad', true);
          timeLapse = 0;
          $('.main.card').find('input').each(function(rowNumber) {
            return updateCards(rowNumber, this.value);
          });
          $('.main.card .defaults').find('input').each(function(rowNumber) {
            var $t, j, timers, v;
            $t = $(this);
            v = $t.val();
            $t.val('');
            timers = (function() {
              var _ref, _results;
              _results = [];
              for (j = 0, _ref = v.length; 0 <= _ref ? j <= _ref : j >= _ref; 0 <= _ref ? j++ : j--) {
                _results.push((function(j) {
                  var timer;
                  timer = setTimeout(function() {
                    var v_substring;
                    v_substring = v.substr(0, j);
                    $t.val(v_substring);
                    return updateCards(rowNumber, v_substring);
                  }, timeLapse * 70);
                  timeLapse++;
                  return timer;
                })(j));
              }
              return _results;
            })();
            $t.bind('clearMe', function() {
              var i, _k, _len3;
              console.log($t.data('cleared'));
              if (!$t.data('cleared')) {
                for (_k = 0, _len3 = timers.length; _k < _len3; _k++) {
                  i = timers[_k];
                  clearTimeout(i);
                }
                $t.val('');
                updateCards(rowNumber, '');
                return $t.data('cleared', true);
              }
            });
            return $t.bind('focus', function() {
              return $t.trigger('clearMe');
            });
          });
        }
      }
      _results = [];
      for (_k = 0, _len3 = hasHidden.length; _k < _len3; _k++) {
        i = hasHidden[_k];
        _results.push(i.thisT - 50 < newWinH ? i.$this.fadeIn(2000) : void 0);
      }
      return _results;
    });
    /*
      Login stuff
      */
    monitorForComplete = function(openedWindow) {
      var checkTimer;
      $.cookie('success-login', null);
      return checkTimer = setInterval(function() {
        if ($.cookie('success-login')) {
          successfulLogin();
          $.cookie('success-login', null);
          window.focus();
          return openedWindow.close();
        }
      }, 200);
    };
    $('.google').click(function() {
      monitorForComplete(window.open('auth/google', 'auth', 'height=350,width=600'));
      return false;
    });
    $('.twitter').click(function() {
      monitorForComplete(window.open('auth/twitter', 'auth', 'height=400,width=500'));
      return false;
    });
    $('.facebook').click(function() {
      monitorForComplete(window.open('auth/facebook', 'auth', 'height=400,width=900'));
      return false;
    });
    $('.linkedin').click(function() {
      monitorForComplete(window.open('auth/linkedin', 'auth', 'height=300,width=400'));
      return false;
    });
    $('.login-form').submit(function() {
      loadLoading({}, function(loadingClose) {
        return $.ajax({
          url: '/login',
          data: {
            email: $('.email-login').val(),
            password: $('.password-login').val()
          },
          success: function(data) {
            loadingClose();
            if (data.err) {
              return loadAlert({
                content: data.err
              });
            } else {
              return successfulLogin();
            }
          },
          error: function(err) {
            loadingClose();
            return loadAlert({
              content: 'Our apologies. A server error occurred.'
            });
          }
        });
      });
      return false;
    });
    $('.new').click(function() {
      loadModal({
        content: '<div class="create-form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>',
        buttons: [
          {
            label: 'Create New',
            action: function(formClose) {
              var email, err, password, password2;
              email = $('.email');
              password = $('.password');
              password2 = $('.password2');
              err = false;
              if (email.val() === '' || password.val() === '' || password2.val() === '') {
                err = 'Please enter an email once and the password twice.';
              } else if (password.val() !== password2.val()) {
                err = 'I\'m sorry, I don\'t think those passwords match.';
              } else if (password.val().length < 4) {
                err = 'Password should be a little longer, at least 4 characters.';
              }
              if (err) {
                return loadAlert({
                  content: err
                });
              } else {
                formClose();
                return loadLoading({}, function(loadingClose) {
                  return $.ajax({
                    url: '/createUser',
                    data: {
                      email: email.val(),
                      password: password.val()
                    },
                    success: function(data) {
                      loadingClose();
                      if (data.err) {
                        return loadAlert({
                          content: data.err
                        });
                      } else {
                        return successfulLogin();
                      }
                    },
                    error: function(err) {
                      loadingClose();
                      return loadAlert({
                        content: 'Our apologies. A server error occurred.'
                      });
                    }
                  }, 1000);
                });
              }
            }
          }
        ],
        height: 340,
        width: 400
      });
      $('.email').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val().match(/.{1,}@.{1,}\..{1,}/)) {
            $t.removeClass('error').addClass('valid');
            return $.ajax({
              url: '/checkEmail',
              data: {
                email: $t.val()
              },
              success: function(fullResponseObject) {
                if (fullResponseObject.count === 0) {
                  $t.removeClass('error').addClass('valid');
                  return $t.showTooltip({
                    message: fullResponseObject.email + ' is good'
                  });
                } else {
                  $t.removeClass('valid').addClass('error');
                  return $t.showTooltip({
                    message: '' + fullResponseObject.email + ' is in use. Try signing in with a social login.'
                  });
                }
              }
            });
          } else {
            return $t.removeClass('valid').addClass('error').showTooltip({
              message: 'Is that an email?'
            });
          }
        }, 1000));
      });
      $('.password').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val().length >= 4) {
            return $t.removeClass('error').addClass('valid');
          } else {
            return $t.removeClass('valid').addClass('error').showTooltip({
              message: 'Just ' + (6 - $t.val().length) + ' more characters please.'
            });
          }
        }, 1000));
      });
      $('.password2').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val() === $('.password').val()) {
            $t.removeClass('error').addClass('valid');
            return $('.step-4').fadeTo(300, 1);
          } else {
            return $t.removeClass('valid').addClass('error').showTooltip({
              message: 'Passwords should match please.'
            });
          }
        }, 1000));
      });
      return false;
    });
    $feedback_a = $('.feedback a');
    $feedback_a.mouseover(function() {
      var $feedback;
      $feedback = $('.feedback');
      return $feedback.stop(true, false).animate({
        right: '-37px'
      }, 250);
    });
    $feedback_a.mouseout(function() {
      var $feedback;
      $feedback = $('.feedback');
      return $feedback.stop(true, false).animate({
        right: '-45px'
      }, 250);
    });
    $feedback_a.click(function() {
      loadModal({
        content: '<div class="feedback-form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback-text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email" cols="40"></p></div>',
        width: 400,
        height: 300,
        buttons: [
          {
            label: 'Send Feedback',
            action: function(formClose) {
              formClose();
              return loadLoading({}, function(loadingClose) {
                return $.ajax({
                  url: '/sendFeedback',
                  data: {
                    content: $('.feedback-text').val(),
                    email: $('.emailNotUser').val()
                  },
                  success: function(data) {
                    loadingClose();
                    if (data.err) {
                      return loadAlert({
                        content: data.err
                      });
                    } else {
                      return successfulFeedback()(function() {
                        $s.html('Feedback Sent');
                        return $s.fadeIn(100000);
                      });
                    }
                  },
                  error: function(err) {
                    loadingClose();
                    return loadAlert({
                      content: 'Our apologies. A server error occurred, feedback could not be sent.'
                    });
                  }
                }, 1000);
              });
            }
          }
        ]
      });
      return false;
    });
    $('#show_activity').change(function() {
      var e;
      $('#activity_container ul').hide('slow');
      e = '#' + $(':selected', $(this)).attr('name');
      return $(e).show('slow');
    });
    $('#activity_container ul').hide();
    $('#show_card_chart').change(function() {
      var e;
      $('#chart_container ul').hide('slow');
      e = '#' + $(':selected', $(this)).attr('name');
      return $(e).show('slow');
    });
    $('#chart_container ul').hide();
    /*
      Shopping Cart Stuff
      */
    item_name = '100 cards';
    $('.checkout').click(function() {
      loadAlert({
        content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
      });
      return false;
    });
    $gs = $('.gallery-select');
    $gs.css({
      left: -220,
      top: 0
    });
    $('.gallery .card').live('click', function() {
      var $findClass, $t, className;
      $t = $(this);
      $('.card').removeClass('active');
      $t.addClass('active');
      $findClass = $t.clone();
      className = $findClass.removeClass('card')[0].className;
      $findClass.remove();
      $('.main').attr({
        "class": 'card main ' + className
      });
      if ($gs.offset().top === $t.offset().top - 10) {
        return $gs.animate({
          left: $t.offset().left - 10
        }, 500);
      } else {
        return $gs.stop(true, false).animate({
          top: $t.offset().top - 10
        }, 500, 'linear', function() {
          return $gs.animate({
            left: $t.offset().left - 10
          }, 500, 'linear');
        });
      }
    });
    $gs.bind('activeMoved', function() {
      $a = $('.card.active');
      return $gs.css({
        left: $a.offset().left - 10,
        top: $a.offset().top - 10
      });
    });
    $(window).load(function() {
      return $('.gallery:first .card:first').click();
    });
    $('.button').live('mouseenter', function() {
      return $(this).addClass('hover');
    }).live('mouseleave', function() {
      return $(this).removeClass('hover');
    }).live('mousedown', function() {
      return $(this).addClass('click');
    }).live('mouseup', function() {
      return $(this).removeClass('click');
    });
    newMargin = 0;
    maxSlides = $('.slides li').length;
    marginIncrement = 620;
    maxSlides--;
    /*
      # Home Page Stuff
      */
    $('.category h4').click(function() {
      var $c, $g, $t;
      $t = $(this);
      $c = $t.closest('.category');
      $g = $c.find('.gallery');
      $a = $('.category.active');
      if (!$c.hasClass('active')) {
        $a.removeClass('active');
        $a.find('.gallery').show().slideUp(400);
        $gs.hide();
        $c.find('.gallery').slideDown(400, function() {
          $gs.show();
          return $c.find('.card:first').click();
        });
        return $c.addClass('active');
      }
    });
    $('.card.main input').each(function(i) {
      var $t;
      $t = $(this);
      $t.data('timer', 0);
      return $t.keyup(function() {
        updateCards(i, this.value);
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
          var arrayOfInputValues;
          $('.card.main input').each(function() {
            return $(this).trigger('clearMe');
          });
          /*
                    # TODO
                    #
                    # this.value should have a .replace ',' '\,'
                    # on it so that we can use a comma character and escape anything.
                    # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
                    */
          arrayOfInputValues = $.makeArray($('.card.main input').map(function() {
            return this.value;
          }));
          console.log(arrayOfInputValues);
          $.ajax({
            url: '/saveForm',
            data: {
              inputs: arrayOfInputValues.join('`~`')
            }
          });
          return false;
        }, 1000));
        return false;
      });
    });
    /*
      # Button Clicking Stuff
      */
    $('.quantity input,.shipping_method input').bind('click change', function() {
      var $q, $s;
      $q = $('.quantity input:checked');
      $s = $('.shipping_method input:checked');
      return $('.order-total .price').html('$' + ($q.val() * 1 + $s.val() * 1));
    });
    $('.main-fields .more').click(function() {
      $('.main-fields .alt').slideDown(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main-fields .less').show();
      return false;
    });
    $('.main-fields .less').hide().click(function() {
      $('.main-fields .alt').slideUp(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main-fields .more').show();
      return false;
    });
    advanceSlide = function() {
      if (newMargin < maxSlides * -marginIncrement) {
        newMargin = 0;
      } else if (newMargin > 0) {
        newMargin = maxSlides * -marginIncrement;
      }
      return $('.slides .content').stop(true, false).animate({
        'margin-left': newMargin
      }, 400);
    };
    $('.slides .arrow-right').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= marginIncrement;
      return advanceSlide();
    });
    $('.slides .arrow-left').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= -marginIncrement;
      return advanceSlide();
    });
    timer = setTimeout(function() {
      marginIncrement = $('.slides').width();
      newMargin -= marginIncrement;
      advanceSlide();
      clearTimeout(timer);
      return timer = setInterval(function() {
        marginIncrement = $('.slides').width();
        newMargin -= marginIncrement;
        return advanceSlide();
      }, 6500);
    }, 3000);
    $slides = $('.slides');
    return $slides.animate({
      'padding-left': '301px'
    });
  });
}).call(this);
