# Bio.Intervals
# =============
#
# Module for genomic intervals.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/Bio.jl/blob/master/LICENSE.md

module Intervals

export
    Strand,
    Interval,
    leftposition,
    hasleftposition,
    rightposition,
    hasrightposition,
    IntervalCollection,
    IntervalStream,
    STRAND_NA,
    STRAND_POS,
    STRAND_NEG,
    STRAND_BOTH,
    coverage,
    isoverlapping,
    seqname,
    hasseqname,
    metadata,
    strand,
    BEDReader,
    BEDWriter,
    BEDMetadata,
    BEDInterval,
    BigBedReader,
    BigBedWriter,
    GFF3,
    GFF3Reader,
    GFF3Metadata,
    GFF3Interval,
    hasfasta,
    getfasta,
    directives,
    Tabix,
    overlapchunks,
    tryread!,
    isfilled,
    MissingFieldException

import Base.Collections: heappush!, heappop!
import Bio.Exceptions: MissingFieldException
import Bio.Ragel: Ragel, tryread!
import Bio.StringFields: StringField
import BufferedStreams: BufferedStreams, BufferedInputStream, upanchor!
import ColorTypes: RGB
import IntervalTrees
import Libz
importall Bio

include("strand.jl")
include("interval.jl")
include("stream_buffer.jl")
include("intervalcollection.jl")
include("intervalstream.jl")
include("index/index.jl")

# Parsing file types
include("bed/bed.jl")
include("bbi/bbi.jl")
include("gff3/gff3.jl")

include("deprecated.jl")

end # module Intervals
