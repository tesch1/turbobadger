#!/usr/bin/env python

#
# generate a doc file from a skin file/path
#

from __future__ import print_function, division
import os, sys
import re

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print('usage:',sys.argv[0],' <path/to/skinfile.tb.txt>')
        exit(1)

    skinfile = sys.argv[1]
    skindir = os.path.dirname(skinfile)
    skindoc = skindir+'/skin.h'
    skin_name = os.path.basename(skindir)
    pngs = []

    # get the image file names from the skin file
    regex = re.compile('\w+\.svg|\w+\.png')
    with open(skinfile, 'r') as f:
        for line in f:
            #print(line)
            pngs += regex.findall(line)

    # dump a doxygen-file with the images & image names
    with open(skindoc, 'w') as f:
        print('/** @page skin_%s Skin %s' % (skin_name, skin_name), file=f)

        i = 0
        print('', file=f)
        print('Skin "%s"' % (skin_name), file=f)
        print('', file=f)
        print('https://github.com/tesch1/turbobadger/blob/hastybadger/resources/%s'
              % (os.path.basename(skinfile)), file=f)
        print('', file=f)
        f.write('<table>\n')
        for img in pngs:
            if i == 0:
                f.write('  <tr>\n')
            #print(' \image ',img, img.split('.')[0])
            f.write('    <td> \image html %s %s\n' % (img, img.split('.')[0]))
            #print('', file=f)
            #f.write('<td> ![%s](%s)' % (img.split('.')[0], img) )
            i = i + 1
            if i == 4:
                i = 0
        f.write('</table> ')

        print('*/', file=f)
    
    print('wrote',skindoc)
