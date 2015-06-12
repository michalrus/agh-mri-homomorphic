# agh-mri-homomorphic
Mathematica implementation of “[Spatially variant noise estimation in MRI A homomorphic approach](http://www.sciencedirect.com/science/article/pii/S1361841514001625).”

## How to run

First, edit the [`config`](/config) file to suit your needs. The program is able to read and write files in CSV and PNG formats.

### Mathematica UI (on UNIX/Windows/…)

Open the [`example.nb`](/example.nb) notebook, edit the path (currently `/home/m/Development/agh/mri-homomorphic/`) to reflect your download location, and run (`Shift`+`Enter`) the first input line. Output files will be created in the directory. You can then run the second input line to display the noisy image, Gaussian map, and Rician map.

![mathematica-screenshot](http://i.imgur.com/KRDzy8t.png)

### Terminal (on UNIX)

```
$ cd agh-mri-homomorphic/
$ ./run
```

The output files will be created according to the `config` file. Also, the run time will be displayed. It’s ~25 seconds on `Intel(R) Core(TM) i7-3537U CPU` for a 256×256 image.

## Known issues

None.

Errors with regard to the [reference implementation](/verification/): 10<sup>-11</sup> ÷ 10<sup>-12</sup>.

## Development/testing environment

Up-to-date [ArchLinux](https://www.archlinux.org/), kernel `Linux arch 4.0.4-2-ARCH`, [Mathematica](https://www.wolfram.com/mathematica/) 10.0 for Linux x86 (64-bit).
