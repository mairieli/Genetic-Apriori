package br.com.dependencias;

import java.util.Map;
import org.repodriller.RepoDriller;
import org.repodriller.RepositoryMining;
import org.repodriller.Study;
import org.repodriller.filter.commit.OnlyInMainBranch;
import org.repodriller.filter.range.Commits;
import org.repodriller.persistence.csv.CSVFile;
import org.repodriller.scm.GitRepository;

public class CollectorStudy implements Study {

    private String projectName = "robotjs";
    private String dir = "/home/mairieliw/pCloudDrive/TCC/projetos/";

    public static void main(String[] args) {
	new RepoDriller().start(new CollectorStudy());
    }

    @Override
    public void execute() {

	ModificationsVisitor visitor = new ModificationsVisitor();

	new RepositoryMining()
		.in(GitRepository.singleProject(dir + projectName))
		.through(Commits.all())
		.filters(new OnlyInMainBranch())
		.process(visitor)
		.withThreads(3)
		.mine();

	CSVFile csvRenamed = new CSVFile(dir + projectName + "_renamedfiles.csv");
	for (Map.Entry<String, String> entry : visitor.getRenamedFiles().entrySet()) {
	    csvRenamed.write(entry.getKey() + ";" + entry.getValue());
	}

	CSVFile csv = new CSVFile(dir + projectName + ".csv");
	for (VisitedCommit v : visitor.getCommits()) {
	    csv.write(v.toString());
	}
    }

}
