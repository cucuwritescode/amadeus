=========
References
=========

This document contains all the academic and technical references cited throughout the Amadeus project documentation and research.

Academic References
==================

Basic Pitch and Music Transcription
------------------------------------

.. [1] R. M. Bittner, J. J. Bosch, D. Rubinstein, G. Meseguer-Brocal, and S. Ewert, "A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation," May 12, 2022, arXiv: arXiv:2203.09893. doi: 10.48550/arXiv.2203.09893.

.. [2] J. Pauwels, K. O'Hanlon, E. Gómez, and M. B. Sandler, "20 YEARS OF AUTOMATIC CHORD RECOGNITION FROM AUDIO," 2019.

Signal Processing and Matrix Factorization
------------------------------------------

.. [3] P. López-Serrano and C. Dittmar, "NMF Toolbox: Music Processing Applications of Nonnegative Matrix Factorization," 2019.

Music Cognition and Key Detection
---------------------------------

.. [6] C. L. Krumhansl, *Cognitive Foundations of Musical Pitch*. Oxford University Press USA, 1990.

Software Framework References
=============================

Audio Processing Frameworks
---------------------------

.. [4] AudioKit Pro, "AudioKit: Swift audio synthesis, processing, and analysis platform," GitHub repository, 2023. [Online]. Available: https://github.com/AudioKit/AudioKit

Music Theory Libraries
---------------------

.. [5] AudioKit Pro, "Tonic: Music theory library for Swift," GitHub repository, 2023. [Online]. Available: https://github.com/AudioKit/Tonic

Additional Technical References
==============================

iOS Development
---------------

* Apple Inc., "Swift Programming Language," 2023. [Online]. Available: https://swift.org/
* Apple Inc., "SwiftUI Framework," 2023. [Online]. Available: https://developer.apple.com/xcode/swiftui/
* Apple Inc., "AVFoundation Framework," 2023. [Online]. Available: https://developer.apple.com/documentation/avfoundation

Python Scientific Computing
---------------------------

* NumPy Community, "NumPy: Scientific computing with Python," 2023. [Online]. Available: https://numpy.org/
* SciPy Community, "SciPy: Scientific tools for Python," 2023. [Online]. Available: https://scipy.org/
* librosa Development Team, "librosa: Audio and music analysis in Python," 2023. [Online]. Available: https://librosa.org/

Web Framework and Server
------------------------

* FastAPI, "FastAPI: Modern, fast web framework for building APIs with Python," 2023. [Online]. Available: https://fastapi.tiangolo.com/

BibTeX Format
=============

For use in LaTeX documents, here are the references in BibTeX format:

.. code-block:: latex

    @misc{bittner2022lightweight,
        title={A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation},
        author={Rachel M. Bittner and Juan José Bosch and David Rubinstein and Gabriel Meseguer-Brocal and Sebastian Ewert},
        year={2022},
        eprint={2203.09893},
        archivePrefix={arXiv},
        primaryClass={eess.AS}
    }

    @article{pauwels2019twenty,
        title={20 Years of Automatic Chord Recognition from Audio},
        author={Pauwels, Johan and O'Hanlon, Ken and G{\'o}mez, Emilia and Sandler, Mark B.},
        year={2019}
    }

    @article{lopez2019nmf,
        title={NMF Toolbox: Music Processing Applications of Nonnegative Matrix Factorization},
        author={L{\'o}pez-Serrano, Patricio and Dittmar, Christian},
        year={2019}
    }

    @book{krumhansl1990cognitive,
        title={Cognitive Foundations of Musical Pitch},
        author={Krumhansl, Carol L.},
        year={1990},
        publisher={Oxford University Press USA}
    }

    @misc{audiokit2023,
        title={AudioKit: Swift audio synthesis, processing, and analysis platform},
        author={AudioKit Pro},
        year={2023},
        howpublished={GitHub repository},
        url={https://github.com/AudioKit/AudioKit}
    }

    @misc{tonic2023,
        title={Tonic: Music theory library for Swift},
        author={AudioKit Pro},
        year={2023},
        howpublished={GitHub repository},
        url={https://github.com/AudioKit/Tonic}
    }