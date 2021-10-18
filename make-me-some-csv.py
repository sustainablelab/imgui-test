#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import math

print("bob")

with open("bob.csv", 'w') as f:
    for i in range(101):
        t = i*(2*math.pi/100)
        x = math.sin(t)
        f.write(f"{t} {x}\n")

