
import unittest

import adventOfCode2019_03
import adventOfCode2019_03/consts


suite "unit-test suite":
    test "getMessage":
        assert(cHelloWorld == getMessage())
