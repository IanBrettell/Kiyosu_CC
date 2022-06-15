# Add distance and angle movement metrics
rule movement_metrics:
    input:
        rules.assign_ref_test.output,
    output:
        os.path.join(
            config["working_dir"],
            "with_metrics/{assay}/{sample}/{quadrant}/{interval}.csv"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/movement_metrics/{assay}/{sample}/{quadrant}/{interval}.log"
        ),
    params:
        seconds_interval = "{interval}",
        source_file = "workflow/scripts/movement_metrics_source.R",
    resources:
        mem_mb = 500
    container:
        config["rocker_tidyverse"]
    script:
        "../scripts/movement_metrics.R"

# Merge all .csvs with metrics into single .csv
rule merge_csvs:
    input:
        expand(os.path.join(
            config["working_dir"],
            "with_metrics/{assay}/{sample}/{quadrant}/{{interval}}.csv"
            ),
                zip,
                assay = ASSAYS_ZIP_TRK,
                sample = SAMPLES_ZIP_TRK,
                quadrant = QUADRANTS_ZIP_TRK
        ),
    output:
        os.path.join(
            config["working_dir"],
            "merged/{interval}.csv"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/merge_csvs/{interval}.log"
        ),
    resources:
        mem_mb = lambda wildcards, attempt: attempt * 50000
    container:
        config["rocker_tidyverse"]
    script:
        "../scripts/merge_csvs.R"

rule send_to_shared_folder:
    input:
        rules.merge_csvs.output,
    output:
        os.path.join(
            config['shared_dir'],
            "{interval}/Kiyosu_CC.csv"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/send_to_shared_folder/{interval}.log"
        ),
    resources:
        mem_mb = 200
    shell:
        """
        cp {input} {output}
        """

#rule get_line_ranks_and_colours:
#    input:
#        rules.merge_csvs.output,
#    output:
#        fig = "book/figs/line_mean_speed/line_mean_speed_{interval}.png",
#        csv = "config/line_colours/line_colours_{interval}.csv"
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/get_line_ranks_and_colours/{interval}.log"
#        ),
#    params:
#        interval = "{interval}"
#    resources:
#        mem_mb = lambda wildcards, attempt: attempt * 15000
#    container:
#        config["R_4.2.0"]
#    script:
#        "../scripts/get_line_ranks_and_colours.R"
#
#rule coloured_trails_labels:
#    input:
#        video_object=rules.track_videos.output.video_obj,
#        trajectories=get_trajectories_file,
#        colours = rules.get_line_ranks_and_colours.output.csv,
#    output:
#        os.path.join(
#            config["working_dir"],
#            "tracked/{interval}/{assay}/{sample}/{quadrant}.avi",
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/coloured_trails_labels/{interval}/{assay}/{sample}/{quadrant}.log"
#        ),
#    params:
#        sample = "{sample}",
#        ref_loc = get_ref_loc,
#    container:
#        config["idtrackerai"]
#    resources:
#        mem_mb=5000,
#    script:
#        "../scripts/coloured_trails_labels.py"
#
#rule stitch_tracked_vids:
#    input:
#        expand(os.path.join(
#            config["working_dir"],
#            "tracked/{{interval}}/{{assay}}/{{sample}}/{quadrant}.avi"
#            ),
#                quadrant = QUADRANTS_ALL
#        ),
#    output:
#        os.path.join(
#            config["working_dir"],
#            "stitched/{interval}/{assay}/{sample}.avi",
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/stitch_tracked_vids/{interval}/{assay}/{sample}.log"
#        ),
#    container:
#        config["opencv"]
#    resources:
#        mem_mb=5000,
#    script:
#        "../scripts/stitch_tracked_vids.py"
#
#rule path_frames_to_vid:
#    input:
#        data = rules.merge_csvs.output,
#        stitched_vid = rules.stitch_tracked_vids.output,
#        colours = rules.get_line_ranks_and_colours.output.csv,
#        dims = rules.get_split_video_dims.output,
#    output:
#        os.path.join(
#            config["working_dir"],
#            "path_vids/{interval}/{assay}/{sample}.avi"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/path_frames_to_vid/{interval}/{assay}/{sample}.log"
#        ),
#    params:
#        assay = "{assay}",
#        sample = "{sample}",
#        tmpdir = config["tmpdir"]
#    resources:
#        mem_mb = 20000,
#    container:
#        config["opencv"]
#    script:
#        "../scripts/path_frames_to_vid.py"
#
#rule compile_two_panel_vid:
#    input:
#        labels = rules.stitch_tracked_vids.output[0],
#        paths = rules.path_frames_to_vid.output[0],
#    output:
#        os.path.join(
#            config["working_dir"],
#            "two_panel_vids/{interval}/{assay}/{sample}.avi"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/compile_two_panel_vid/{interval}/{assay}/{sample}.log"
#        ),
#    resources:
#        mem_mb = 5000,
#    container:
#        config["opencv"]
#    script:
#        "../scripts/compile_two_panel_vid.py"
#
#rule two_panel_short:
#    input:
#        rules.compile_two_panel_vid.output,
#    output:
#        avi = os.path.join(
#            config["working_dir"],
#            "two_panel_short_vids/{interval}/{assay}/{sample}.avi"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/two_panel_short/{interval}/{assay}/{sample}.log"
#        ),
#    params:
#        tot_sec = 60,
#    resources:
#        mem_mb = 5000,
#    container:
#        config["opencv"]
#    script:
#        "../scripts/two_panel_short.py"         

#
#rule run_hmm:
#    input:
#        rules.merge_csvs.output,
#    output:
#        os.path.join(
#            config["working_dir"],
#            "hmm_out/{interval}/{variables}/{n_states}.csv"
#        ),        
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/hmm/{interval}/{variables}/{n_states}.log"
#        ),
#    params:
#        n_states = "{n_states}",
#        variables = lambda wildcards: config["hmm_variables"][wildcards.variables]
#    resources:
#        # start at 5000
#        mem_mb = lambda wildcards, attempt: attempt * 5000,
#    container:
#        config["hmmlearn"]
#    script:
#        "../scripts/run_hmm.py"
#
## We also want to test the concordance between the assigned states
## when the HMM is trained on a different dataset
## Randomise order of videos for 0.5 split into train and test datasets
#rule hmm_concordance_in:
#    input:
#        rules.merge_csvs.output,
#    output:
#        A = os.path.join(
#            config["working_dir"],
#            "hmm_concordance_in/{interval}/A.csv"
#        ),
#        B = os.path.join(
#            config["working_dir"],
#            "hmm_concordance_in/{interval}/B.csv"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/hmm_cocordance_input/{interval}.log"
#        ),
#    resources:
#        mem_mb = 5000
#    container:
#        config["rocker_tidyverse"]
#    script:
#        "../scripts/hmm_concordance_input.R"
#
## Run concordance
#rule hmm_concordance_out:
#    input:
#        A = rules.hmm_concordance_in.output.A,
#        B = rules.hmm_concordance_in.output.B,
#    output:
#        os.path.join(
#            config["working_dir"],
#            "hmm_concordance_out/{interval}/{variables}/{n_states}.csv"
#        ),  
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/hmm_concordance_out/{interval}/{variables}/{n_states}.log"
#        ),
#    params:
#        n_states = "{n_states}",
#        variables = lambda wildcards: config["hmm_variables"][wildcards.variables]
#    resources:
#        # start at 5000
#        mem_mb = lambda wildcards, attempt: attempt * 15000,
#    container:
#        config["hmmlearn"]
#    script:
#        "../scripts/hmm_concordance.py"    
